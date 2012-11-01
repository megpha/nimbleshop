class Admin::OrdersController < AdminController

  respond_to :html

  def capture_payment
    respond_to do |format|
      format.html do
        @order = Order.find_by_number! params[:id]
        @order.payment_method.kapture! @order
        redirect_to admin_order_path(@order), notice: "Amount was successfully captured"
      end
    end
  end

  def purchase_payment
    respond_to do |format|
      format.html do
        @order = Order.find_by_number! params[:id]
        @order.purchase!
        redirect_to admin_order_path(@order), notice: "Amount was successfully paid"
      end
    end
  end

  def index
    @orders = Order.order('id desc')
    respond_with @orders
  end

  def show
    @order = Order.find_by_number! params[:id]

    if @order.shipments.any?
      @shipment = @order.shipments.first
    else
      @shipment = @order.shipments.build
      @shipment.notify_customer = 1
    end

    respond_with @order
  end

end
