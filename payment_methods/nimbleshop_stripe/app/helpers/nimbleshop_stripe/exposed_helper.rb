module NimbleshopStripe
  module ExposedHelper

    def nimbleshop_stripe_crud_form
      return unless NimbleshopStripe::Stripe.first
      render partial: '/nimbleshop_stripe/stripes/edit'
    end

    def nimbleshop_stripe_picture_on_admin_payment_methods
      image_tag 'engines/nimbleshop_stripe/stripe.png', alt: 'stripe logo'
    end

    def nimbleshop_stripe_payment_form(order)
      return unless NimbleshopStripe::Stripe.first
      render partial: '/nimbleshop_stripe/payments/new', locals: { order: order }
    end

  end
end
