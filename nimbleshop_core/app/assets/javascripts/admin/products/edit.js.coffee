window.Nimbleshop = window.Nimbleshop || {}

$ ->
  # work around the nested form ugliness
  $("form input:file").parents('.fields').hide()




Nimbleshop.managePicture = class ManagePicture
  constructor: ->
    @deletePicture()
    @makePictureSortable()

  deletePicture: ->
    $('[data-behavior~=delete-product-picture]').on 'click', ->
      $("#delete_picture_" + $(this).attr("data-action-id")).trigger "click"
      $(this).parent().parent().hide "fast"
      false

   makePictureSortable: ->
    $(".product_pictures").sortable(update: ->
      order = {}
      $(".product_pictures li").each (index, elem) ->
        order[index] = $(elem).attr("data-id")

      $("#product_pictures_order").attr "value", $.toJSON(order)
    ).disableSelection()

Nimbleshop.manageVariants = class ManageVariants
  constructor: ->
    @initActions()
  addVariantRow: ->
    newid   = new Date().getTime() 
    matcher = /(\[|_)\d+(\]|_)/g
    content = ($ ".variant tbody tr:first").clone()
    content.find('input').removeAttr('value')
    $('<tr/>').append content.html().replace(matcher, "$1#{newid}$2")
  addRow: =>
    ($ ".variant tbody").append @addVariantRow
    false
  addColumn: =>
    for element in ($ ".variant tr:not(.silver)")
      $element = ($ element)
      html = $element.find('td:first,th:first').clone().find('input').removeAttr('value')
      $($element.find('td,th').get(0)).before(html)
    false
  initActions: ->
    ($ "a[data-behaviour='product-variants-add-row']").click 'addrow', @addRow 
    ($ "a[data-behaviour='product-variants-add-column']").click 'addrow', @addColumn

$ ->
  new Nimbleshop.managePicture
  new Nimbleshop.manageVariants
