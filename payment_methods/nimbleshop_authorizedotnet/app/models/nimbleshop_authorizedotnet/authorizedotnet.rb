module NimbleshopAuthorizedotnet
  class Authorizedotnet < PaymentMethod

    store_accessor :metadata, :api_login_id, :transaction_key, :business_name, :mode, :ssl

    before_save :set_mode, :set_ssl

    validates_presence_of :api_login_id, message: "^Api Login Id can't be blank"
    validates_presence_of :transaction_key, :business_name

    def credentials
      { login: api_login_id, password: transaction_key }
    end

    def use_ssl?
      self.ssl == 'enabled'
    end

    def kapture!(order, processor_klass = nil)
      processor_klass ||= NimbleshopAuthorizedotnet::Processor
      processor = processor_klass.new(order: order, payment_method: self)

      processor.kapture transaction_gid: order.payment_transactions.last.transaction_gid
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
