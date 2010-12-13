;(function ($) {

  var annotations = []

  $.mockjax({
    url: '/annotations/store',
    contentType: 'text/json',
    responseText: annotations
  })


})(jQuery)

