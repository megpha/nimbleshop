module Nimbleshop
  module PaymentUtil
    extend self

    def billing_address_json(order)
      a = order.real_billing_address

      { address1: a.address1,
        city:     a.city,
        state:    a.state_name,
        country:  a.country_name,
        zip:      a.zipcode }
    end

    def shipping_address_json(order)
      a = order.shipping_address

      { first_name: a.first_name,
        last_name:  a.last_name,
        address1:   a.address1,
        city:       a.city,
        state:      a.state_name,
        country:    a.country_name,
        zip:        a.zipcode }
    end

    def activemerchant_options(order)
      billing_address = { billing_address: billing_address(order) }
      shipping_address = { shipping_address: shipping_address(order) }
      misc = { order_id: order.number, email: order.email }
      billing_address.merge(shipping_address).merge(misc)
    end

  end
end

