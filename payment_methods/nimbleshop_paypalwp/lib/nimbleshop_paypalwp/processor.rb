module NimbleshopPaypalwp
  class Processor < Processor::Base

    attr_reader :order, :payment_method, :notify

    def initialize(options = {})
      options.symbolize_keys!
      options.assert_valid_keys :raw_post
      raw_post = options.fetch :raw_post

      @notify = ActiveMerchant::Billing::Integrations::Paypal::Notification.new raw_post
      @order = Order.find_by_number! notify.invoice
      @payment_method = NimbleshopPaypalwp::Paypalwp.first
    end

    private

    def do_capture(options = {})
      if success = ipn_from_paypal?
        record_transaction 'captured'
        order.update_attributes(purchased_at: purchased_at, payment_method: payment_method)
        order.kapture
      end

      success
    end

    def do_authorize(options = {})
      if success = ipn_from_paypal?
        record_transaction 'authorized'
        order.update_attributes(purchased_at: purchased_at, payment_method: payment_method)
        order.authorize
      end

      success
    end

    def do_void(options = {})
    end

    def do_purchase(options = {})
      if success = ipn_from_paypal?
        record_transaction 'purchased'
        order.update_attributes(purchased_at: notify.received_at, payment_method: payment_method)
        order.purchase
      end

      success
    end

    def record_transaction(operation, options = {})
      order.payment_transactions.create(options.merge(amount: notify.amount.cents,
                                                      params: { ipn: notify.raw },
                                                      transaction_gid: notify.transaction_id,
                                                      operation: operation))
    end

    def ipn_from_paypal?
      result = amount_match? && notify.complete? && business_email_match? && notify_acknowledge
      Rails.logger.debug "ipn_from_paypal? : #{result}"
      result
    end

    def notify_acknowledge
      Rails.env.test? ? true : notify.acknowledge
    end

    def business_email_match?
      return true if Rails.env.test?

      result = notify.account ==  payment_method.merchant_email
      Rails.logger.debug "business_email_match? : #{result}"
      result
    end

    def amount_match?
      result = notify.amount.cents == order.total_amount_in_cents
      Rails.logger.debug "amount_match? : #{result}"
      result
    end

    def purchased_at
      Time.strptime(notify.params['payment_date'], "%H:%M:%S %b %d, %Y %z")
    end
  end
end
