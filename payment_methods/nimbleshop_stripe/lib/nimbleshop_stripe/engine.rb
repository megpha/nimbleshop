module NimbleshopStripe
  class Engine < ::Rails::Engine

    isolate_namespace NimbleshopStripe

    config.to_prepare do
      ::NimbleshopStripe::Stripe
    end

    initializer 'nimbleshop_stripe.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper NimbleshopStripe::ExposedHelper
      end
    end

  end
end
