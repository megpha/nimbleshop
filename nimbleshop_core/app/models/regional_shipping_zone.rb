class RegionalShippingZone < ShippingZone

  validates :state_code, presence: true, uniqueness: { scope: :country_shipping_zone_id }

  validate :validate_state_code, if: lambda { |r| r.state_code && r.country }

  before_save :set_name

  delegate :country, to: :country_shipping_zone, allow_nil: true

  private

  def validate_state_code
    country = country_shipping_zone.country
    unless country.subregions.coded(state_code)
      errors.add(:state_code, "#{state_code} is an invalid regional code for country #{country.name}")
    end
  end

  def set_name
    country = country_shipping_zone.country
    self.name = country.subregions.coded(state_code).name
  end

end
