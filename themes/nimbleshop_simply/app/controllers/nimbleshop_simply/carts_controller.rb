module NimbleshopSimply
  class CartsController < SimplyController

    respond_to :html

    def show
      @line_items = current_order.blank? ? [] : current_order.line_items(include: :product).order('id')
      respond_with @line_items
    end

    def add
      product = Product.find_by_permalink!(params[:permalink])
      variant = Variant.find_by_id(params[:variant])
      session[:order_id] = Order.create!.id unless current_order
      current_order.add(product, variant)
      redirect_to cart_url
    end

    def checkingout
      redirect_to new_checkout_shipping_address_path
    end

    def update
      current_order.update_quantity(params[:updates])
      redirect_to cart_url
    end

  end
end
