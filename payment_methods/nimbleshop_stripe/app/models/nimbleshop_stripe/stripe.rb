module NimbleshopStripe
  class Stripe < PaymentMethod

    store_accessor :metadata, :publishable_key, :secret_key, :business_name, :mode, :ssl

    before_save :set_mode, :set_ssl

    validates_presence_of :publishable_key, :business_name, :secret_key

    def use_ssl?
      self.ssl == 'enabled'
    end

    def kapture!(order)
      processor = NimbleshopAuthorizedotnet::Processor.new order
      processor.kapture
      order.kapture!
    end

    private

    def set_mode
      self.mode ||= 'test'
    end

    def set_ssl
      self.ssl ||= 'disabled'
    end

  end
end
