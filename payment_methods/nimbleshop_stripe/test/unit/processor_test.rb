require 'test_helper'

module Processor
  class NimbleshopStripePurchaseTest < ActiveRecord::TestCase

    TOKEN = 'tok_0eLPgnVqeoGqWd'

    setup do
      payment_method     = NimbleshopStripe::Stripe.first
      assert_equal 'test', payment_method.mode.to_s
      assert_equal 'Stripe', payment_method.name
      @order = create(:order)
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopStripe::Processor.new(order: @order, payment_method: payment_method)
    end

    test 'when purchase succeeds' do
      transactions_count = @order.payment_transactions.count

      playcasette('stripe/purchase-success') do
        assert_equal true, @processor.purchase(token: TOKEN)
      end

      @order.reload

      transaction = @order.payment_transactions.last
      assert_equal 'purchased', transaction.operation
      assert_equal NimbleshopStripe::Stripe.first, @order.payment_method
      assert       @order.purchased?
      assert_equal transactions_count + 1, @order.payment_transactions.count
      assert_equal 'ch_0eLWIXVivQp0KE', transaction.transaction_gid
    end

    test 'purchase fails when  token number is not entered' do
      transactions_count = @order.payment_transactions.count

      playcasette('stripe/purchase-failure') do
        assert_equal false, @processor.purchase(token: 'xxxxxx')
        assert_equal "Credit card was declined. Please try again!", @processor.errors.first
      end

      @order.reload

      assert_nil    @order.payment_method
      assert        @order.abandoned?
      assert_equal transactions_count, @order.payment_transactions.count
    end
  end

  class NimbleshopStripeRefundTest < ActiveRecord::TestCase

    TOKEN = 'tok_0g3n2A0IthHLzf'

    setup do
      payment_method     = NimbleshopStripe::Stripe.first
      assert_equal 'test', payment_method.mode.to_s
      assert_equal 'Stripe', payment_method.name
      @order = create(:order)
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopStripe::Processor.new(order: @order, payment_method: payment_method)
      playcasette('stripe/purchase-success-for-refund') do
        assert_equal true, @processor.purchase(token: TOKEN)
      end
      @transaction = @order.payment_transactions.last
    end

    test 'when refund succeeds' do
      assert_equal 'ch_0g3pxaKlHho2cr', @transaction.transaction_gid
      playcasette('stripe/refund-success') do
        assert_equal true, @processor.refund(transaction_gid:   'ch_0g3pxaKlHho2cr',
                                             card_number:       @transaction.metadata[:card_number])
      end
      @order.reload
      assert       @order.refunded?
    end
  end
end
