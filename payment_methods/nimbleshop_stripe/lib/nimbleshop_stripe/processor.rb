module NimbleshopStripe
  class Processor < Processor::Base

    attr_reader :order, :payment_method, :errors, :gateway

    def initialize(options)
      @errors = []
      @order = options.fetch :order
      @payment_method = options.fetch :payment_method
      @gateway = ::NimbleshopStripe::Gateway.instance payment_method
      ::Stripe.api_key = payment_method.secret_key
    end

    private

    def set_active_merchant_mode # :nodoc:
      ActiveMerchant::Billing::Base.mode = payment_method.mode.to_sym
    end

    def do_authorize(options = {})
      do_purchase options
    end

    # Creates purchase for the order amount.
    #
    # === Options
    #
    # * <tt>:token</tt> -- token to be charged. This is a required field.
    #
    # This method returns false if purchase fails. Error messages are in <tt>errors</tt> array.
    # If purchase succeeds then <tt>order.purchase</tt> is invoked.
    #
    def do_purchase(options = {})
      options.symbolize_keys!
      options.assert_valid_keys :token

      token = options.fetch :token

      response = gateway.purchase(order.total_amount_in_cents, token)

      if response.success?
        # record transaction only if the operation was a success. Because if the operation was a failure then
        # getting Token.retrieve will throw exception
        ::Nimbleshop::PaymentTransactionRecorder.new(payment_transaction_recorder_hash(response, token)).record

        order.update_attributes(payment_method: payment_method)
        order.purchase!
      else
        Rails.logger.info response.params['error']['message']
        @errors << 'Credit card was declined. Please try again!'
      end

      response.success?
    end

    def payment_transaction_recorder_hash(response, token)
      token_response = ::Stripe::Token.retrieve token

      {  response: response,
         order: order,
         operation: :purchased,
         transaction_gid: response.authorization,
         metadata: {  fingerprint: token_response.card.fingerprint,
                      livemode: token_response.livemode,
                      card_number: "XXXX-XXXX-XXXX-#{token_response.card.last4}",
                      cardtype: token_response.card.type.downcase }}
    end

    def do_void(options = {})
      raise 'Stripe does not support void operation'
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
        ::Nimbleshop::PaymentTransactionRecorder.new(transaction_gid: response.authorization, response: response, operation: :refunded, order: order).record
        order.refund
      else
        @errors << "Refund operation failed"
      end

      response.success?
    end

  end
end
