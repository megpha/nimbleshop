module NimbleshopPaypalwp

  # Following line makes it possible to use this gem without nimbleshop_core
  klass = defined?(::Admin::PaymentMethodsController) ? ::Admin::PaymentMethodsController : ActionController::Base

  class PaypalwpsController < klass

    protect_from_forgery except: :notify

    before_filter :load_payment_method, except: :notify

    def notify
      processor = NimbleshopPaypalwp::Processor.new(raw_post: request.raw_post)
      order = processor.order

      # order is already in purchased state. Seems like IPN is sending duplicate notification
      processor.purchase unless order.purchased?

      render nothing: true
    end

    def update
      alert_msg = if @payment_method.update_attributes(post_params[:paypalwp])
                    msg = "Record has been updated"
                    %Q[alert("#{msg}")]
                  else
                    msg =  @payment_method.errors.full_messages.first
                    %Q[alert("#{msg}")]
                  end

      respond_to do |format|
        format.js { render js: alert_msg }
      end
    end

    private

    def post_params
      params.permit(paypalwp: [:merchant_email, :mode])
    end

    def load_payment_method
      @payment_method = NimbleshopPaypalwp::Paypalwp.first
    end

  end
end
