require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  setup do
    @product = create(:product, 
                      price: 199.99, 
                      name: 'iphone', 
                      variant_labels: %w[color size],
                      description: 'phone + ipod')
    @white = @product.variants.create(values: { color: 'red', size: '32gb' }, quantity: 2, price: 100)
    @black = @product.variants.create(values: { color: 'red', size: '16gb' }, quantity: 2, price: 0)
    @line_item = create(:line_item, product: @product, quantity: 10)
  end

  test 'price' do
    assert_equal 1999.9, @line_item.total
  end

  test 'update_quantity to zero' do
    @line_item.update_quantity(0)
    assert @line_item.destroyed?
  end

  test 'update_quantity to nonzero' do
    @line_item.update_quantity(12)
    assert !@line_item.destroyed?
    assert_equal 12, @line_item.quantity

    @line_item.update_quantity('11')
    assert_equal 11, @line_item.quantity
  end

  test 'copy product properties' do
    assert_equal 199.99,    @line_item.product_price
    assert_equal 'iphone',  @line_item.product_name
    assert_equal 'phone + ipod', @line_item.product_description
  end

  test 'copy product variant attributes' do
    @line_item.update_attributes(variant: @white)

    expected = { color: 'red', size: '32gb' }
    assert_equal expected, @line_item.variant_values
    assert_equal 199.99, @line_item.product_price
    assert_equal 299.99, @line_item.price
  end
end
