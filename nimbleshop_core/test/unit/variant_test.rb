require 'test_helper'

class VariantTest < ActiveRecord::TestCase
  setup do
    @variant = Variant.new(values: { color: 'red', size: 'medium' }, 
                           quantity: 2,
                           price: 12.3)
  end

  test 'to_hash' do
    expected = {color: 'red', id: nil, size: 'medium', quantity: 2, price: 12.3}
    assert_equal expected, @variant.to_hash
  end
end
