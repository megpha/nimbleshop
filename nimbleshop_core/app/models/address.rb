class Address < ActiveRecord::Base

  validates_presence_of :first_name, :last_name, :address1, :zipcode, :country_code, :city

  CREDIT_CARD_ATTRIBUTES = %w(address1 address2 zipcode first_name last_name)

  belongs_to :order

  validate :validate_and_set_country_name, :validate_and_set_state_name

  def full_address_array
    [name, address1, address2, city_state_zip, country_name].compact
  end

  def name
    [first_name, last_name].compact.join(' ')
  end

  def address_lines(join_chars = ', ')
    [address1, address2].delete_if { |add| add.blank? }.join(join_chars)
  end

  def city_state_name
    [city, state_name].join(', ')
  end

  def city_state_zip
    [city_state_name, zipcode].join(' ')
  end

  def to_credit_card_attributes
    attributes.slice(*CREDIT_CARD_ATTRIBUTES).merge('state' => state_name)
  end

  private

  def validate_and_set_country_name
    if country = Carmen::Country.coded(country_code)
      self.country_name = country.name
    else
      errors.add(:country_code, "#{country_code} is not a valid country code")
    end
  end

  def validate_and_set_state_name
    country = Carmen::Country.coded(country_code)
    return unless country

    if state_code.blank?
      errors.add(:state_code, "is required")
    elsif state = country.subregions.coded(state_code)
      self.state_name = state.name
    else
      errors.add(:state_code, "#{state_code} is not a valid state")
    end
  end
end

class BillingAddress < Address
end

class ShippingAddress < Address
end
