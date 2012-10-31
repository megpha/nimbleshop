require 'test_helper'

module Processor
  class NimbleshopStripeTest < ActiveRecord::TestCase

    TOKEN = 'tok_0eLPgnVqeoGqWd'

    setup do
      payment_method     = NimbleshopStripe::Stripe.first
      #assert_equal 'tbd', payment_method.inspect
      assert_equal 'test', payment_method.mode.to_s
      assert_equal 'Stripe', payment_method.name
      @order = create(:order)
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopStripe::Processor.new(order: @order, payment_method: payment_method)
    end

    test 'when purchase succeeds' do
      creditcard = build(:creditcard)

      playcasette('stripe/purchase-success') do
        assert_equal true, @processor.purchase(token: TOKEN)
      end

      @order.reload

      transaction = @order.payment_transactions.last
      assert_equal 'purchased', transaction.operation
      assert_equal true, transaction.success
      assert_equal NimbleshopStripe::Stripe.first, @order.payment_method
      assert       @order.purchased?
    end

    test 'purchase fails when  token number is not entered' do

      creditcard = build(:creditcard, number: nil)

      playcasette('stripe/purchase-failure') do
        assert_equal false, @processor.purchase(token: 'xxxxxx')
        assert_equal "Credit card was declined. Please try again!", @processor.errors.first
      end

      @order.reload

      assert_nil    @order.payment_method
      assert        @order.abandoned?
    end

  end
end
