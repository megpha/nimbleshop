window.Nimbleshop = window.Nimbleshop || {}

Nimbleshop.managePaymentMethods = class ManagePaymentMethods
  constructor: ->
    @editPaymentForm()
    @selectFirstPaymentMethod()

  editPaymentForm: ->
    $('[data-behavior~=payment-method-edit-link]').on 'click', ->
      $this = $(this)
      permalink = $this.data('payment-method-permalink')
      console.log permalink
      contentElem = $("[data-behavior~=payment-method-form-#{permalink}]")
      contentElem.parent().children().hide()
      contentElem.show()

  selectFirstPaymentMethod: ->
    $('[data-behavior~=payment-method-edit-link]:first').trigger('click')


$ ->
  new Nimbleshop.managePaymentMethods
