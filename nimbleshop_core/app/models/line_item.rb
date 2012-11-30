class LineItem < ActiveRecord::Base
  # this is used only to pull the picture of the line_item. If after an order is created a product
  # is deleted then that product and all the pictures are gone. In that case line item should
  # display image not available. Besides image line_item should not pull any data from product and
  # instead used the attributes copied from product to line_item
  belongs_to :product
  belongs_to :variant

  store :metadata, accessors: [ :picture_tiny,      
    :picture_small,      
    :picture_medium,      
    :picture_large,
    :picture_tiny_plus, 
    :picture_small_plus, 
    :picture_medium_plus, 
    :picture_large_plus,
    :product_permalink,
    :product_name, 
    :product_price, 
    :product_description, 
    :product_permalink, 
    :variant_values,
    :variant_price
  ]

  belongs_to :order

  validates_presence_of :order_id
  validates_presence_of :product_id
  validates_numericality_of :quantity, minimum: 1

  before_save :copy_product_attributes, if: :product_id_changed?
  before_save :copy_variant_attributes
  before_save :copy_price

  def total
    price * quantity
  end

  def update_quantity(count)
    count.to_i.zero? ?  destroy : update_attributes(quantity: count)
  end

  private

  def copy_product_attributes
    %w[name description price permalink].each do | attribute |
      send("product_#{attribute}=", product.send(attribute))
    end

    [
      :tiny,
      :tiny_plus,
      :small, 
      :small_plus, 
      :medium, 
      :medium_plus, 
      :large,
      :large_plus
    ].each do |size|
      send("picture_#{size}=", product.picture.picture_url(size.intern))
    end
  end

  def copy_variant_attributes
    %w[values price].each do | attribute |
      send("variant_#{attribute}=", current_variant.send(attribute))
    end
  end

  def copy_price
    self.price = product_price + variant_price
  end

  def current_variant
    variant || NullVariant.new
  end

  class NullVariant
    def values
      {}
    end

    def price
      0
    end
  end

  class NullPicture
    def picture_url(picture_type)
      nil
    end
  end
end
