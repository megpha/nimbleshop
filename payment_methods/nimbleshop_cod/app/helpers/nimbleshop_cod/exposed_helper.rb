module NimbleshopCod
  module ExposedHelper

    def nimbleshop_cod_next_payment_processing_action(order)
      if order.pending?
        link_to 'Mark payment as received', purchase_payment_admin_order_path(order), method: :put, class: 'btn btn-success'
      end
    end

    def nimbleshop_cod_small_image(options = {} )
      image_tag 'engines/nimbleshop_cod/cod_small.png', {alt: 'cod icon'}.merge(options)
    end

    def nimbleshop_cod_picture_on_admin_payment_methods
      image_tag 'engines/nimbleshop_cod/cod_big.png', alt: 'cod logo'
    end

    def nimbleshop_cod_available_payment_options_icons
      return nil # do not display any payment option icon for cash on delivery
    end

    def nimbleshop_cod_payment_form(order)
      return unless NimbleshopCod::Cod.first
      render partial: '/nimbleshop_cod/payments/new', locals: { order: order }
    end

    def nimbleshop_cod_crud_form
      return unless NimbleshopCod::Cod.first
      render partial: '/nimbleshop_cod/cods/edit'
    end

    def nimbleshop_cod_icon_for_order_payment(order)
      nimbleshop_cod_small_image( height: '13px' )
    end

  end
end
