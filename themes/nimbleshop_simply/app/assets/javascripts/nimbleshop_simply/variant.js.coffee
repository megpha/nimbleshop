window.manageVariants = class Variant
  constructor: ->
    @price =  $('#product-price').data().price
    @labels = $('.variant-selectors').map (i, selectField) -> 
      $(selectField).data().name

    @variants = $('.variants-info').map (i, element) => 
      variant = $(element).data()

    @variantsArray = @variants.map (i, variant) =>
      $.makeArray(@labels.map (k, inner) -> variant[inner])

    ($ '.variant-selectors').live 'change', @updateProductPrice

    $($('.variant-selectors:first')).trigger('change')

  updateProductPrice: =>
    if variant = @matchingVariant()
      @updateCheckoutButton(variant)
    else
      @disableCheckout()

  matchingVariant: ->
    @variants[@variantsArray.index(@currentVariantCombination())]

  disableCheckout: ->
    $('#product-price').
        html 'not available'
    $('#variant').removeAttr('value')
    $("#buy").hide()

  updateCheckoutButton: (variant) ->
    $('#product-price').
        html accounting.formatMoney(@price + variant.price)
    $('#variant').attr('value', variant.id)
    $("#buy").show()

  currentVariantCombination: ->
    $('.variant-selectors').map (i, e) -> $(e).attr('value')

$ ->
  new window.manageVariants()
