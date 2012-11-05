require 'test_helper'

module Processor

  class NimbleshopAuthorizeNetAuthorizeTest < ActiveRecord::TestCase
    setup do
      payment_method     = NimbleshopAuthorizedotnet::Authorizedotnet.first
      @order = create :order
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopAuthorizedotnet::Processor.new(order: @order, payment_method: payment_method)
    end

    test 'when authorization succeeds' do
      creditcard = build :creditcard
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/authorize-success') do
        assert_equal true, @processor.authorize(creditcard: creditcard)
      end

      @order.reload

      transaction = @order.payment_transactions.last
      assert_equal 'authorized', transaction.operation
      assert_equal NimbleshopAuthorizedotnet::Authorizedotnet.first, @order.payment_method
      assert       @order.authorized?
      assert_equal 'visa', transaction.metadata[:cardtype]
      assert_equal transactions_count + 1, @order.payment_transactions.count
    end

    test 'authorization fails when credit card number is not entered' do
      creditcard = build(:creditcard, number: nil)
      transactions_count = @order.payment_transactions.count

      assert_equal false, @processor.authorize(creditcard: creditcard)
      assert_equal 'Please enter credit card number', @processor.errors.first

      @order.reload

      assert_nil    @order.payment_method
      assert        @order.abandoned?
      assert_equal transactions_count, @order.payment_transactions.count
    end

    test 'authorization fails with invalid credit card number' do
      creditcard = build(:creditcard, number: 2)
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/authorize-failure') do
        assert_equal false, @processor.authorize(creditcard: creditcard)
        assert_equal 'Credit card was declined. Please try again!', @processor.errors.first
      end

      @order.reload

      assert_nil    @order.payment_method
      assert        @order.abandoned?
      assert_equal transactions_count, @order.payment_transactions.count
    end
  end

  class AuthorizeNetCaptureTest < ActiveRecord::TestCase
    setup do
      payment_method     = NimbleshopAuthorizedotnet::Authorizedotnet.first
      @order     = create(:order, payment_method: payment_method)
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopAuthorizedotnet::Processor.new(order: @order, payment_method: payment_method)
      creditcard = build :creditcard

      playcasette('authorize.net/authorize-success') do
        @processor.authorize(creditcard: creditcard)
      end

      @tsx_id = @order.payment_transactions.last.transaction_gid
    end

    test 'when capture succeeds' do
      creditcard = build :creditcard
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/capture-success') do
        assert_equal true, @processor.kapture(transaction_gid: @tsx_id)
      end

      @order.reload
      transaction = @order.payment_transactions.last
      assert_equal  'captured', transaction.operation
      assert_equal "XXXX-XXXX-XXXX-0027", transaction.metadata[:card_number]
      assert_equal 'visa', transaction.metadata[:cardtype]
      assert        @order.purchased?
      assert_equal transactions_count + 1, @order.payment_transactions.count
    end

    test 'when capture fails' do
      creditcard = build(:creditcard, number: 2)
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/capture-failure') do
        assert_equal false, @processor.kapture(transaction_gid: @tsx_id)
        assert_equal 'Capture operation failed', @processor.errors.first
      end

      @order.reload

      assert       @order.authorized?
      assert_equal transactions_count, @order.payment_transactions.count
    end
  end

  class AuthorizeNetRefundTest < ActiveRecord::TestCase
    setup do
      payment_method     = NimbleshopAuthorizedotnet::Authorizedotnet.first
      @order = create(:order)
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopAuthorizedotnet::Processor.new(order: @order, payment_method: payment_method)
      creditcard = build(:creditcard)

      playcasette('authorize.net/purchase-success') do
        assert_equal true, @processor.purchase(creditcard: creditcard)
      end

      assert @order.reload.purchased?

      @transaction = @order.payment_transactions.last
    end

    test 'when refund succeeds' do
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/refund-success') do
        assert_equal true, @processor.refund(transaction_gid:   @transaction.transaction_gid,
                                             card_number:       @transaction.metadata[:card_number])
      end

      @order.reload
      transaction = @order.payment_transactions.last

      assert_equal  'refunded', transaction.operation
      assert_equal  NimbleshopAuthorizedotnet::Authorizedotnet.first, @order.payment_method
      assert        @order.refunded?
      assert_equal transactions_count + 1, @order.payment_transactions.count
    end

    test 'when refund fails' do
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/refund-failure') do
        assert_equal false, @processor.refund(transaction_gid: @transaction.transaction_gid, card_number: '1234')
      end

      @order.reload

      assert        @order.purchased?
      assert_equal transactions_count, @order.payment_transactions.count
    end
  end

  class AuthorizeNetVoidTest < ActiveRecord::TestCase
    setup do
      payment_method     = NimbleshopAuthorizedotnet::Authorizedotnet.first
      @order = create :order
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopAuthorizedotnet::Processor.new(order: @order, payment_method: payment_method)
      creditcard = build :creditcard

      playcasette('authorize.net/authorize-success') do
        assert_equal true, @processor.authorize(creditcard: creditcard)
      end

      @tsx_id = @order.payment_transactions.last.transaction_gid
    end

    test 'when void succeeds' do
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/void-success') do
        assert_equal true, @processor.void(transaction_gid: @tsx_id)
      end

      @order.reload
      transaction = @order.payment_transactions.last

      assert_equal  'voided', transaction.operation
      assert_equal  NimbleshopAuthorizedotnet::Authorizedotnet.first, @order.payment_method
      assert        @order.voided?
      assert_equal transactions_count + 1, @order.payment_transactions.count
    end

    test 'when void fails' do
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/void-failure') do
        assert_equal false, @processor.void(transaction_gid: @tsx_id)
      end

      @order.reload
      assert        @order.authorized?
      assert_equal transactions_count, @order.payment_transactions.count
    end
  end

  class AuthorizeNetPurchaseTest < ActiveRecord::TestCase
    setup do
      payment_method     = NimbleshopAuthorizedotnet::Authorizedotnet.first
      @order = create :order
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopAuthorizedotnet::Processor.new(order: @order, payment_method: payment_method)
    end

    test 'when purchase succeeds' do
      creditcard = build :creditcard
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/purchase-success') do
        assert_equal true, @processor.purchase(creditcard: creditcard)
      end

      @order.reload

      transaction = @order.payment_transactions.last
      assert_equal  'purchased', transaction.operation
      assert        @order.purchased?
      assert_equal transactions_count + 1, @order.payment_transactions.count
    end

    test 'purchase fails when credit card number is not entered ' do
      creditcard = build(:creditcard, number: nil)
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/purchase-failure') do
        assert_equal false, @processor.purchase(creditcard: creditcard)
        assert_equal 'Please enter credit card number', @processor.errors.first
      end

      assert       @order.abandoned?
      assert_equal transactions_count, @order.payment_transactions.count
    end

    test 'purchase fails when invalid credit card number is entered' do
      creditcard = build(:creditcard, number: 2)
      transactions_count = @order.payment_transactions.count

      playcasette('authorize.net/purchase-failure') do
        assert_equal false, @processor.purchase(creditcard: creditcard)
        assert_equal 'Credit card was declined. Please try again!', @processor.errors.first
      end

      assert       @order.abandoned?
      assert_equal transactions_count, @order.payment_transactions.count
    end
  end
end
