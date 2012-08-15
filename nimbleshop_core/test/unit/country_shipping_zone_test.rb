require 'test_helper'

class CountryShippingZoneTest < ActiveRecord::TestCase

  test "assigns name from carmen" do
    assert_equal "United States", create(:country_shipping_zone).name
  end

  test "should create all regions for canada" do
    regions = Carmen::Country.coded('CA').subregions.length

    assert_difference 'RegionalShippingZone.count', regions do
      create(:country_shipping_zone, country_code: 'CA')
    end
  end

end
