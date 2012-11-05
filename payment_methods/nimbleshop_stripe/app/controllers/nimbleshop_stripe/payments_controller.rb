module NimbleshopStripe

  class PaymentsController < ::ActionController::Base

    def create
      order             =  Order.find_by_id! session[:order_id]
      token             =  params[:stripeToken]

      address_attrs     = order.final_billing_address.to_credit_card_attributes
      creditcard_attrs  = params[:creditcard].merge(address_attrs)
      creditcard        = Creditcard.new creditcard_attrs

      payment_method    = NimbleshopStripe::Stripe.first
      processor         = NimbleshopStripe::Processor.new({order: order, payment_method: payment_method})

      default_action = Shop.current.default_creditcard_action

      if processor.send(default_action, token: token)
        url = nimbleshop_simply.order_path order
        @output = "window.location='#{url}'"
      else
        error = processor.errors.first
        Rails.logger.info "Error: #{error}"
        @output = "alert('#{error}')"
      end

      respond_to do |format|
        format.js do
          render js: @output
        end
      end

    end

  end

end
