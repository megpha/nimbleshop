class VariantBuilder
  attr_reader :labels, :values

  def initialize(options = {})
    @labels, @values = options[:labels], options[:values]
  end

  def variants
    values.map { | row | OpenStruct.new(construct_struct(row)) }
  end

  private

  def construct_struct(row)
    {}.tap do | attrs |
      labels.each_with_index do | key, idx | 
        attrs.update(key => row[idx])
      end
      quantity, price = row[row.length - 2, row.length - 1]
      attrs.update(price: price.to_f, quantity: quantity.to_i)
    end
  end
end
