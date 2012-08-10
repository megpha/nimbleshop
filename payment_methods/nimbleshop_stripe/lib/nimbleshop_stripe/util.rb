module NimbleshopAuthorizedotnet
  module Util
    extend self

    def billing_address(order)
      { address1: order.real_billing_address.address1,
        city: order.real_billing_address.city,
        state: order.real_billing_address.state_name,
        country: order.real_billing_address.country_name,
        zip: order.real_billing_address.zipcode }
    end

    def shipping_address(order)
      { first_name: order.shipping_address.first_name,
        last_name: order.shipping_address.last_name,
        address1: order.shipping_address.address1,
        city: order.shipping_address.city,
        state: order.shipping_address.state_name,
        country: order.shipping_address.country_name,
        zip: order.shipping_address.zipcode }
    end

    # In this method am stands for activemerchant
    def am_options(order)
      billing_address = { billing_address: billing_address(order) }
      shipping_address = { shipping_address: shipping_address(order) }
      misc = { order_id: order.number, email: order.email }
      billing_address.merge(shipping_address).merge(misc)
    end
  end
end
