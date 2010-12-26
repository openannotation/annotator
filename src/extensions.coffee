$ = jQuery

$.fn.textNodes = ->
  getTextNodes = (node) ->
    if node.nodeType isnt Node.TEXT_NODE
      $(node).contents().map(-> getTextNodes(this)).get()
    else
      node

  this.map -> _.flatten(getTextNodes(this))

$.fn.xpath = (relativeRoot) ->
  jq = this.map ->
    path = ''
    elem = this

    while elem?.nodeType == Node.ELEMENT_NODE and elem isnt relativeRoot
      idx = $(elem.parentNode).children(elem.tagName).index(elem) + 1

      idx  =  if idx > 1 then "[#{idx}]" else ""
      path = "/" + elem.tagName.toLowerCase() + idx + path
      elem = elem.parentNode

    path

  jq.get()


