module NimbleshopCod

  class CodsController < ::Admin::PaymentMethodsController

    before_filter :load_payment_method

    def update
      alert_msg = if @payment_method.update_attributes(post_params[:cod])
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
      params.permit(cod: [:name])
    end

    def load_payment_method
      @payment_method = NimbleshopCod::Cod.first
    end

  end

end
