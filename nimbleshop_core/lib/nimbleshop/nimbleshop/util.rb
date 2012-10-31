module Nimbleshop
  class Util

    # loads a yaml based configuration file and returns hash
    def self.config2hash(file)
      hash = YAML.load(ERB.new(File.read(file)).result)

      common_hash = hash['common'] || {}
      env_hash = hash[Rails.env.to_s] || {}

      final_hash = common_hash.deep_merge(env_hash)
      Hashr.new(final_hash)
    end

    # Converts the amount in cents and returns an integer.
    def self.in_cents(amount)
      (BigDecimal(amount.to_s) * 100).round(0).to_i
    end

    # returns public url for a given localhost url
    #
    # Usage: localhost2public_url ( '/nimbleshop_paypal/notify', 'http' )
    #
    def self.localhost2public_url(url, protocol)
      if Nimbleshop.config.use_localhost2public_url
        public_url = Nimbleshop.config.localhost2public_url
        raise "localhost2public_url value is #{public_url}. It must start with http" unless public_url =~ /^http/
        public_url + url
      else
        url
      end
    end

    # returns an array like this
    # ["Timor-Leste", "TL"], ["Turkmenistan", "TM"], ["Tunisia", "TN"], ["Tonga", "TO"], .......
    def self.name_and_code_of_countries_with_subregions
      Carmen::Country.all.select { |c| c.subregions? }.map { |t| [t.name, t.alpha_2_code] }
    end

    def self.countries_without_shipping_zone
      Nimbleshop::Util.name_and_code_of_countries_with_subregions.reject { |_, t| CountryShippingZone.all_country_codes.include?(t) }
    end

    def self.disabled_shipping_zone_countries
      countries_with_shipping_zone.reduce([]) { |result, element| result << [element[0], element[1], {disabled: :disabled}]}
    end

    def self.unconfigured_shipping_zone_countries
      (Nimbleshop::Util.disabled_shipping_zone_countries + Nimbleshop::Util.countries_without_shipping_zone).sort
    end

    def self.countries_with_shipping_zone
      Nimbleshop::Util.name_and_code_of_countries_with_subregions.select { |_, t| CountryShippingZone.all_country_codes.include?(t)}
    end

  end
end
