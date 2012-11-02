module NimbleshopAuthorizedotnet

  # this line makes it possible to use this gem without nimbleshop_core
  klass = defined?(::Admin::PaymentMethodsController) ? ::Admin::PaymentMethodsController : ActionController::Base

  class AuthorizedotnetsController < klass

    before_filter :load_payment_method

    def update
      alert_msg = if @payment_method.update_attributes(post_params[:authorizedotnet])
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
      params.permit(authorizedotnet: [:mode, :ssl, :login_id, :transaction_key, :business_name])
    end

    def load_payment_method
      @payment_method = NimbleshopAuthorizedotnet::Authorizedotnet.first
    end

  end

end
