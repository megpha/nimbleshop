module NimbleshopSimply
  module SimplyHelper

    # returns nil if the product does not have a main picture
    def product_main_picture(product, version = :medium_plus)
      if pic = product.picture
        image_tag(pic.picture_url(version), alt: product.name)
      end
    end

    def items_count_in_cart
      current_order.blank? ? 0 : current_order.item_count
    end

    def options_for_country(country_code)
      grouped_options_for_country_state_codes[country_code]
    end

    def options_for_countries(country_codes)
      country_codes.map {|t| [ Carmen::Country.coded(t).name, t ] }
    end

    def options_for_variant(product, variant_label)
      options = product.variants.map do | variant |
        [ variant.to_hash[variant_label.to_sym], 
          variant.to_hash[variant_label.to_sym]]
      end.uniq

      options_for_select(options)
    end
  end
end
