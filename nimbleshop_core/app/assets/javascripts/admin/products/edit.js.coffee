$ ->
  # work around the nested form ugliness
  $("form input:file").parents('.fields').hide()



window.Nimbleshop = {} if typeof(Nimbleshop) == 'undefined'

Nimbleshop.managePicture = class ManagePicture
  constructor: ->
    @deletePicture()
    @makePictureSortable()

  deletePicture: ->
    $(".product_pictures .actions .delete").on "click", ->
      $("#delete_picture_" + $(this).attr("data-action-id")).trigger "click"
      $(this).parent().parent().hide "fast"
      false

   makePictureSortable: ->
    $(".product_pictures").sortable(update: (_, __) ->
      order = {}
      $(".product_pictures li").each (index, elem) ->
        order[index] = $(elem).attr("data-id")

      $("#product_pictures_order").attr "value", $.toJSON(order)
    ).disableSelection()


$ ->
  new Nimbleshop.managePicture
