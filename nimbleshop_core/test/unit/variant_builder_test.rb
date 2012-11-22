require 'test_helper'

class VariantBuilderTest < ActiveRecord::TestCase
  test "should able to build" do
    builder = VariantBuilder.new(labels: %w[color size], values: [%w[green 2 4 12.89], %w[red 12 14 1.99]])
    expected = [ OpenStruct.new(size: '2', color: 'green', quantity: 4, price: 12.89), OpenStruct.new(size: '12', color: 'red', quantity: 14, price: 1.99) ]

    assert_equal expected, builder.variants
  end
end
