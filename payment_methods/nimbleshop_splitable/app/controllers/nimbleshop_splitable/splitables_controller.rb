module NimbleshopSplitable
  class SplitablesController < ::Admin::PaymentMethodsController

    protect_from_forgery except: [:notify]

    before_filter :load_payment_method

    def notify
      Rails.logger.info "splitable callback received: #{params.to_yaml}"

      processor = NimbleshopSplitable::Processor.new(invoice: params[:invoice])

      if processor.acknowledge(params)
        render nothing: true
      else
        Rails.logger.info "webhook with data #{params.to_yaml} was rejected. error: #{processor.errors.join(',')}"
        render "error: #{error}", status: 403
      end
    end

    def update
      alert_msg = if @payment_method.update_attributes(post_params[:splitable])
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
      params.permit(splitable: [ :api_key, :api_secret, :expires_in, :mode] )
    end

    def load_payment_method
      @payment_method = NimbleshopSplitable::Splitable.first
    end

  end
end
