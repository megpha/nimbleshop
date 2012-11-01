class PaymentMethod < ActiveRecord::Base

  store :metadata

  scope :ascending, order('id asc')
  scope :enabled,  where(enabled: true)
  scope :disabled, where(enabled: false)

  include Permalink::Builder

  # By default payment_method does not require that application must use SSL.
  # Individual payment method should override this method.
  def use_ssl?
    false
  end

  def demodulized_underscore
    self.class.name.demodulize.underscore
  end

  def self.partialize
    name.gsub("PaymentMethod::","").underscore
  end
end
