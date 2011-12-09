class ShippingMethod < ActiveRecord::Base

  belongs_to :shipping_zone

  validates :lower_price_limit, presence: true
  validates :shipping_price,    presence: true
  validates :name,              presence: true

  # indicates if the shipping method is available for the given order
  def available_for(order)
    if upper_price_limit
      (order.amount >= lower_price_limit) && (order.amount <= upper_price_limit)
    else
      order.amount >= lower_price_limit
    end
  end

end
