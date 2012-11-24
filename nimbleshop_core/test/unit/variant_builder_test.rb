require 'test_helper'

class VariantBuilderTest < ActiveRecord::TestCase
  setup do
    @product = Product.new(variant_labels: %w[color size], 
                           variant_rows: [%w[green 2 4 12.89], %w[red 12 14 1.99]])
    @builder = VariantBuilder.new(@product)
    @builder.rebuild
  end

  test "constructs two variants" do
    assert_equal 2, @product.variants.length
  end

  test 'construct with given options' do
    green = @product.variants[0]
    expected = { color: 'green', 
                 size: 2 ,
                 quantity: 4,
                 price: 12.89 }

    assert_equal expected, green.to_hash
    red = @product.variants[0]
  end
end
