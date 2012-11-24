class VariantBuilder
  attr_reader :product
  delegate :variant_labels, :variant_rows, to: :product

  def initialize(product)
    @product = product
  end

  def rebuild
    product.variants.each(&:mark_for_destruction)

    variant_rows.each do | row | 
      product.variants.build(attributes_for_variant(row))
    end

    true
  end

  private

  def attributes_for_variant(row)
    VariantData.new(variant_labels, row).to_attributes
  end

  class VariantData
    def initialize(labels, values)
      @price    = values.pop
      @quantity = values.pop
      @values   = values
      @labels   = labels
    end

    def to_attributes
      { values: values, price: price, quantity: quantity }
    end

    private

    def price
      @price.to_f
    end
    def quantity
      @quantity.to_i
    end

    def values
      hash = {}
      @labels.each_with_index do | key, idx | 
        hash.update(key.to_sym => @values[idx])
      end

      hash
    end
  end
end
