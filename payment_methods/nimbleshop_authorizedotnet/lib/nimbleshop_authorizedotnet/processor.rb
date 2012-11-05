module NimbleshopAuthorizedotnet
  class Processor < Processor::Base

    attr_reader :order, :payment_method, :errors, :gateway

    def initialize(options)
      options.symbolize_keys!
      options.assert_valid_keys :order, :payment_method

      @errors = []
      @order = options.fetch :order
      @payment_method = options.fetch :payment_method
      @gateway = ::NimbleshopAuthorizedotnet::Gateway.instance payment_method
    end

    private

    def set_active_merchant_mode # :nodoc:
      ActiveMerchant::Billing::Base.mode = payment_method.mode.to_sym
    end

    # Creates authorization for the order amount.
    #
    # === Options
    #
    # * <tt>:creditcard</tt> -- Credit card to be charged. This is a required field.
    #
    # This method returns false if authorization fails. Error messages are in <tt>errors</tt> array.
    # If authorization succeeds then <tt>order.authorize</tt> is invoked.
    #
    def do_authorize(options = {})
      options.symbolize_keys!
      options.assert_valid_keys :creditcard

      creditcard = options.fetch :creditcard

      unless valid_card?(creditcard)
        @errors.push(*creditcard.errors.full_messages)
        return false
      end

      response = gateway.authorize(order.total_amount_in_cents, creditcard, ::Nimbleshop::PaymentUtil.activemerchant_options(order))

      if response.success?
        recorder = ::Nimbleshop::PaymentTransactionRecorder.new(order: order,
                                                                response: response,
                                                                operation: :authorized,
                                                                transaction_gid: get_transaction_gid(response),
                                                                metadata: { card_number: creditcard.display_number, cardtype: creditcard.cardtype})
        recorder.record
        order.update_attributes(payment_method: payment_method)
        order.authorize
      else
        @errors << 'Credit card was declined. Please try again!'
      end

      response.success?
    end


    # Creates purchase for the order amount.
    #
    # === Options
    #
    # * <tt>:creditcard</tt> -- Credit card to be charged. This is a required field.
    #
    # This method returns false if purchase fails. Error messages are in <tt>errors</tt> array.
    # If purchase succeeds then <tt>order.purchase</tt> is invoked.
    #
    def do_purchase(options = {})
      options.symbolize_keys!
      options.assert_valid_keys :creditcard

      creditcard = options.fetch :creditcard

      unless valid_card?(creditcard)
        @errors.push(*creditcard.errors.full_messages)
        return false
      end

      response = gateway.purchase(order.total_amount_in_cents, creditcard)

      if response.success?
        recorder = ::Nimbleshop::PaymentTransactionRecorder.new(order: order,
                                                                response: response,
                                                                operation: :purchased,
                                                                transaction_gid: get_transaction_gid(response),
                                                                metadata: { card_number: creditcard.display_number, cardtype: creditcard.cardtype})
        recorder.record

        order.update_attributes(payment_method: payment_method)
        order.purchase
      else
        @errors << 'Credit card was declined. Please try again!'
      end

      response.success?
    end

    # Captures the previously authorized transaction.
    #
    # === Options
    #
    # * <tt>:transaction_gid</tt> -- transaction_gid is the transaction id returned by the gateway. This is a required field.
    #
    # This method returns false if capture fails. Error messages are in <tt>errors</tt> array.
    # If purchase succeeds then <tt>order.kapture</tt> is invoked.
    #
    def do_kapture(options = {})
      options.symbolize_keys!
      options.assert_valid_keys :transaction_gid
      transaction_gid = options.fetch :transaction_gid
      payment_transaction = PaymentTransaction.find_by_transaction_gid! transaction_gid

      response = gateway.capture(order.total_amount_in_cents, transaction_gid, {})

      if response.success?
        recorder = ::Nimbleshop::PaymentTransactionRecorder.new(order: order,
                                                                response: response,
                                                                operation: :captured,
                                                                transaction_gid: get_transaction_gid(response),
                                                                metadata: { card_number: payment_transaction.metadata[:card_number],
                                                                            cardtype: payment_transaction.metadata[:cardtype]})
        recorder.record
        order.kapture
      else
        @errors << "Capture operation failed"
      end

      response.success?
    end

    # Voids the previously authorized transaction.
    #
    # === Options
    #
    # * <tt>:transaction_gid</tt> -- transaction_gid is the transaction id returned by the gateway. This is a required field.
    #
    # This method returns false if void fails. Error messages are in <tt>errors</tt> array.
    # If void succeeds then <tt>order.void</tt> is invoked.
    #
    def do_void(options = {})
      options.symbolize_keys!
      options.assert_valid_keys :transaction_gid
      transaction_gid = options.fetch :transaction_gid

      response = gateway.void(transaction_gid, {})

      if response.success?
        recorder = ::Nimbleshop::PaymentTransactionRecorder.new(order: order,
                                                                response: response,
                                                                operation: :voided,
                                                                transaction_gid: get_transaction_gid(response))
        recorder.record
        order.void
      else
        @errors << "Void operation failed"
      end

      response.success?
    end

    # Refunds the given transaction.
    #
    # === Options
    #
    # * <tt>:transaction_gid</tt> -- transaction_gid is the transaction id returned by the gateway. This is a required field.
    #
    # This method returns false if refund fails. Error messages are in <tt>errors</tt> array.
    # If refund succeeds then <tt>order.refund</tt> is invoked.
    #
    def do_refund(options = {})
      options.symbolize_keys!
      options.assert_valid_keys :transaction_gid, :card_number

      transaction_gid      = options.fetch :transaction_gid
      card_number = options.fetch :card_number

      response = gateway.refund(order.total_amount_in_cents, transaction_gid, card_number: card_number)

      if response.success?
        recorder = ::Nimbleshop::PaymentTransactionRecorder.new(order: order,
                                                                response: response,
                                                                operation: :refunded,
                                                                transaction_gid: get_transaction_gid(response))
        recorder.record
        order.refund
      else
        @errors << "Refund failed"
      end

      response.success?
    end

    def valid_card?(creditcard) # :nodoc:
      creditcard && creditcard.valid?
    end

    # Following code invokes response.authorization to get transaction id. Note that this method can be called
    # after capture or refund. And it feels weird to call +authorization+ when the operation was +capture+.
    # However this is how ActiveMerchant works. It sets transaction id in +authorization+ key.
    #
    # https://github.com/Shopify/active_merchant/blob/master/lib/active_merchant/billing/gateways/authorize_net.rb#L283
    def get_transaction_gid(response)
      response.authorization
    end

  end
end
