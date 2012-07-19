window.Nimbleshop = {} if typeof(Nimbleshop) == 'undefined'

Nimbleshop.managePaymentMethods = class ManagePaymentMethods
  constructor: ->
    @cancelPaymentForm()
    @editPaymentForm()

  cancelPaymentForm: ->
    $(".nimbleshop-payment-method-form .cancel").click ->
      $this = $(this)
      div = $this.closest(".nimbleshop-payment-method-form-well")
      div.hide()  if div.length
      false

  editPaymentForm: ->
    $(".nimbleshop-payment-method-edit").click ->
      $this = $(this)
      well = $this.parent("div").find(".nimbleshop-payment-method-form-well")
      if well.length
        visible = well.is(":visible")
        well.toggle(!visible)
      false


$ ->
  new Nimbleshop.managePaymentMethods
