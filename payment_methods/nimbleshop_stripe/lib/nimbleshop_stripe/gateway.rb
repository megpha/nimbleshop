module NimbleshopStripe
  module Gateway
    def self.instance(payment_method)
      ActiveMerchant::Billing::Gateway.logger = Rails.logger if payment_method.mode.to_s == 'test'

      ActiveMerchant::Billing::StripeGateway.new( login: payment_method.publishable_key )
    end
  end
end
