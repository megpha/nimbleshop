module NimbleshopStripe
  module ExposedHelper

    def nimbleshop_stripe_crud_form
      return unless NimbleshopStripe::Stripe.first
      render partial: '/nimbleshop_stripe/stripes/edit'
    end

    def nimbleshop_stripe_picture_on_admin_payment_methods
      image_tag 'engines/nimbleshop_stripe/stripe.png', alt: 'stripe logo'
    end

  end
end
