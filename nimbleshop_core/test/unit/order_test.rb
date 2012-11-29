require 'test_helper'

class OrderAddressTest < ActiveSupport::TestCase

  test "shipping and billing address is nil" do
    order = Order.new(billing_address: nil, shipping_address: nil)
    assert_nil  order.final_billing_address
  end

  test "billing address is same as shipping address" do
    shipping_address = ShippingAddress.new(use_for_billing: true)
    order = Order.new(shipping_address: shipping_address, billing_address: BillingAddress.new)
    assert_equal shipping_address, order.final_billing_address
  end

  test "billing address is different from shipping address" do
    shipping_address = ShippingAddress.new(use_for_billing: false)
    billing_address = BillingAddress.new
    order = Order.new(shipping_address: shipping_address, billing_address: billing_address)
    assert_equal billing_address, order.final_billing_address
  end

end

class OrderTest < ActiveSupport::TestCase
  setup do
    @order = create :order
    @product1 = create :product, price: 10
    @product2 = create :product, price: 30
  end

  test 'default factory created order has initialized payment status and shipping status' do
    assert_equal 'abandoned', @order.payment_status
    assert_equal 'nothing_to_ship', @order.shipping_status
  end

  test "factory" do
    order = create :order_paid_using_authorizedotnet
    assert_equal 1, order.payment_transactions.size
  end

  test "#add" do
    @order.add(@product1)
    assert_equal 1, @order.line_items.size
    assert_equal 1, @order.line_items.first.quantity
  end

  test "#remove" do
    @order.add(@product1)
    @order.remove(@product1)
    assert @order.reload.line_items.empty?
    assert_equal 0.0, @order.reload.line_items_total.to_f
  end

  test "#update_quantity" do
    @order.add(@product1)
    @order.update_quantity({@product1.id => 20})
    assert_equal 20, @order.line_items.first.quantity
  end

  test "#update_quantity when order has 2 items" do
    @order.add(@product1)
    @order.add(@product2)
    @order.update_quantity({@product1.id => 3})
    assert_equal 60.0, @order.line_items_total.to_f
  end

  test "#available_shipping_methods" do
    @order.add(create(:product))
    assert_equal 1, @order.available_shipping_methods.size
    assert_equal 58, ShippingMethod.count
    @order.shipping_address = create(:shipping_address)
    assert_equal 1, @order.available_shipping_methods.size
  end

  test '#purchase!' do
    refute @order.purchased_at
    payment_method = ::NimbleshopStripe::Stripe.first
    assert payment_method
    @order.update_attributes!(payment_method: payment_method)
    @order.purchase!
    assert_equal 'shipping_pending', @order.shipping_status
    assert_equal 'purchased', @order.payment_status
    assert @order.purchased_at
  end

  test '#authorize!' do
    refute @order.purchased_at
    payment_method = ::NimbleshopAuthorizedotnet::Authorizedotnet.first
    assert payment_method
    @order.update_attributes!(payment_method: payment_method)
    @order.authorize!
    assert_equal 'shipping_pending', @order.shipping_status
    assert_equal 'authorized', @order.payment_status
    assert @order.purchased_at
  end

  test '#pending!' do
    refute @order.purchased_at
    payment_method = ::NimbleshopCod::Cod.first
    assert payment_method
    @order.update_attributes!(payment_method: payment_method)
    @order.pending!
    assert_equal 'shipping_pending', @order.shipping_status
    assert_equal 'pending', @order.payment_status
    assert @order.purchased_at
  end

end
