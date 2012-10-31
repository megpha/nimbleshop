require 'test_helper'

module Processor
  class NimbleshopAuthorizeNetAuthorizeTest < ActiveRecord::TestCase
    setup do
      payment_method     = NimbleshopAuthorizedotnet::Authorizedotnet.first
      @order = create(:order)
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopAuthorizedotnet::Processor.new(order: @order, payment_method: payment_method)
    end

    test 'when authorization succeeds' do
      creditcard = build(:creditcard)

      playcasette('authorize.net/authorize-success') do
        assert_equal true, @processor.authorize(creditcard: creditcard)
      end

      @order.reload

      transaction = @order.payment_transactions.last
      assert_equal 'authorized', transaction.operation
      assert_equal true, transaction.success
      assert_equal NimbleshopAuthorizedotnet::Authorizedotnet.first, @order.payment_method
      assert       @order.authorized?
    end

    test 'authorization fails when credit card number is not entered' do
      creditcard = build(:creditcard, number: nil)
      assert_equal false, @processor.authorize(creditcard: creditcard)
      assert_equal 'Please enter credit card number', @processor.errors.first

      @order.reload

      assert_nil    @order.payment_method
      assert        @order.abandoned?
    end

    test 'authorization fails with invalid credit card number' do
      creditcard = build(:creditcard, number: 2)

      playcasette('authorize.net/authorize-failure') do
        assert_equal false, @processor.authorize(creditcard: creditcard)
        assert_equal 'Credit card was declined. Please try again!', @processor.errors.first
      end

      @order.reload

      assert_nil    @order.payment_method
      assert        @order.abandoned?
    end
  end

  class AuthorizeNetCaptureTest < ActiveRecord::TestCase
    setup do
      payment_method     = NimbleshopAuthorizedotnet::Authorizedotnet.first
      @order     = create(:order, payment_method: payment_method)
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopAuthorizedotnet::Processor.new(order: @order, payment_method: payment_method)
      creditcard = build(:creditcard)

      playcasette('authorize.net/authorize-success') do
        @processor.authorize(creditcard: creditcard)
      end

      @tsx_id = @order.payment_transactions.last.transaction_gid
    end

    test 'when capture succeeds' do
      creditcard = build(:creditcard)

      playcasette('authorize.net/capture-success') do
        assert_equal true, @processor.kapture(transaction_gid: @tsx_id)
      end

      @order.reload
      transaction = @order.payment_transactions.last
      assert_equal  'captured', transaction.operation
      assert_equal  true, transaction.success
      assert_equal "XXXX-XXXX-XXXX-0027", transaction.metadata[:card_number]
      assert_equal 'visa', transaction.metadata[:cardtype]
      assert        @order.purchased?
    end

    test 'when capture fails' do
      creditcard = build(:creditcard, number: 2)

      playcasette('authorize.net/capture-failure') do
        assert_equal false, @processor.kapture(transaction_gid: @tsx_id)
        assert_equal 'Capture operation failed', @processor.errors.first
      end

      @order.reload

      transaction = @order.payment_transactions.last

      assert_equal false, transaction.success
      assert_equal 'captured', transaction.operation
      assert       @order.authorized?
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

      playcasette('authorize.net/refund-success') do
        assert_equal true, @processor.refund(transaction_gid:   @transaction.transaction_gid,
                                             card_number:       @transaction.metadata[:card_number])
      end

      @order.reload
      transaction = @order.payment_transactions.last

      assert_equal  'refunded', transaction.operation
      assert_equal  true, transaction.success
      assert_equal  NimbleshopAuthorizedotnet::Authorizedotnet.first, @order.payment_method
      assert        @order.refunded?
    end

    test 'when refund fails' do

      playcasette('authorize.net/refund-failure') do
        assert_equal false, @processor.refund(transaction_gid: @transaction.transaction_gid, card_number: '1234')
      end

      @order.reload

      transaction = @order.payment_transactions.last

      assert_equal 'refunded', transaction.operation
      assert_equal false, transaction.success
    end
  end

  class AuthorizeNetVoidTest < ActiveRecord::TestCase
    setup do
      payment_method     = NimbleshopAuthorizedotnet::Authorizedotnet.first
      @order = create(:order)
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopAuthorizedotnet::Processor.new(order: @order, payment_method: payment_method)
      creditcard = build(:creditcard)

      playcasette('authorize.net/authorize-success') do
        assert_equal true, @processor.authorize(creditcard: creditcard)
      end

      @tsx_id = @order.payment_transactions.last.transaction_gid
    end

    test 'when capture succeeds' do
      playcasette('authorize.net/void-success') do
        assert_equal true, @processor.void(transaction_gid: @tsx_id)
      end

      @order.reload
      transaction = @order.payment_transactions.last

      assert_equal  'voided', transaction.operation
      assert_equal  true, transaction.success
      assert_equal  NimbleshopAuthorizedotnet::Authorizedotnet.first, @order.payment_method
      assert        @order.voided?
    end

    test 'when void fails' do
      playcasette('authorize.net/void-failure') do
        assert_equal false, @processor.void(transaction_gid: @tsx_id)
      end

      @order.reload

      transaction = @order.payment_transactions.last

      assert_equal 'voided', transaction.operation
      assert_equal false, transaction.success
    end
  end

  class AuthorizeNetPurchaseTest < ActiveRecord::TestCase
    setup do
      payment_method     = NimbleshopAuthorizedotnet::Authorizedotnet.first
      @order = create(:order)
      @order.stubs(:total_amount).returns(100.48)
      @processor = NimbleshopAuthorizedotnet::Processor.new(order: @order, payment_method: payment_method)
    end

    test 'when purchase succeeds' do
      creditcard = build(:creditcard)

      playcasette('authorize.net/purchase-success') do
        assert_equal true, @processor.purchase(creditcard: creditcard)
      end

      @order.reload

      transaction = @order.payment_transactions.last
      assert_equal  'purchased', transaction.operation
      assert_equal  true, transaction.success
      assert        @order.purchased?
    end

    test 'purchase fails when credit card number is not entered ' do
      creditcard = build(:creditcard, number: nil)

      playcasette('authorize.net/purchase-failure') do
        assert_equal false, @processor.purchase(creditcard: creditcard)
        assert_equal 'Please enter credit card number', @processor.errors.first
      end

      assert       @order.abandoned?
    end

    test 'purchase fails when invalid credit card number is entered' do
      creditcard = build(:creditcard, number: 2)

      playcasette('authorize.net/purchase-failure') do
        assert_equal false, @processor.purchase(creditcard: creditcard)
        assert_equal 'Credit card was declined. Please try again!', @processor.errors.first
      end

      transaction = @order.payment_transactions.last

      assert_equal false, transaction.success
      assert_equal 'purchased', transaction.operation
      assert       @order.abandoned?
    end
  end
end
