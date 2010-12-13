;(function($){

$.fn.textNodes = function () {
  function getTextNodes(node) {
    if (node.nodeType !== Node.TEXT_NODE) {
      return $(node).contents().map(function () {
        return getTextNodes(this)
      }).get()
    } else {
      return node
    }
  }
  return this.map(function () {
    return _(getTextNodes(this)).flatten()
  })
}

$.fn.xpath = function (relativeRoot) {
  return this.map(function () {
    var path = ''
    for ( var elem = this
        ; elem && elem.nodeType == Node.ELEMENT_NODE && elem !== relativeRoot
        ; elem = elem.parentNode) {

      var idx = $(elem.parentNode).children(elem.tagName).index(elem) + 1

      idx  = idx > 1 ? '[' + idx + ']' : ''
      path = '/' + elem.tagName.toLowerCase() + idx + path
    }
    return path
  }).get()
}

})(jQuery)