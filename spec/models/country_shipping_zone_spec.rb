require 'spec_helper'

describe CountryShippingZone do
  describe "#validations" do

    it "should succed on valid carmen country code" do
      zone = CountryShippingZone.new(carmen_code: 'US')
      zone.valid?

      zone.errors[:carmen_code].must_be(:empty?)
    end

    it "raise errors on invalid carmen country code" do
      zone = CountryShippingZone.new(carmen_code: 'ZZ')
      zone.valid?

      zone.errors[:carmen_code].wont_be(:empty?)
    end

    it "raise errors on nil carmen code" do
      zone = CountryShippingZone.new
      zone.valid?

      zone.errors[:carmen_code].wont_be(:empty?)
    end
  end

  describe "#callbacks" do
    it "should create all regions from canada" do
      canada  = CountryShippingZone.create(carmen_code: 'CA', name: 'Canada')
      regions = Carmen::Country.coded("CA").subregions

      canada.regional_shipping_zones.length.must_equal regions.length
    end

    it "should create all regions from usa" do
      usa     = CountryShippingZone.create(carmen_code: 'US', name: 'USA')
      regions = Carmen::Country.coded("US").subregions

      usa.regional_shipping_zones.length.must_equal regions.length
    end
  end

  describe "#create_by_carmen_code" do
    it "should create by carmen code" do
      zone    = CountryShippingZone.create_by_carmen_code('US')
      country = Carmen::Country.coded("US")
      zone.name.must_equal country.name
    end

    it "should return nil for invalid carmen code" do
      CountryShippingZone.create_by_carmen_code('ZZ').must_be(:nil?)
    end
  end
end
