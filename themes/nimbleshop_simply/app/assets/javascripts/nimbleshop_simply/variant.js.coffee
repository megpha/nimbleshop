window.manageVariants = class Variant
  constructor: ->
   @loadData
  refreshVariantInfo: =>

  loadData: ->
    @variants = $.map  ($ '.variants-info'), (element) ->  $(element).data()
  initSeletors: ->
    ($ '.variant-selectors').live 'change', @refreshVariantInfo

$ ->
  new window.manageVariants()
