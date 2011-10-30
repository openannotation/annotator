# I18N
gettext = null

if Gettext?
  _gettext = new Gettext(domain: "annotator")
  gettext = (msgid) -> _gettext.gettext(msgid)
else
  gettext = (msgid) -> msgid

_t = (msgid) -> gettext(msgid)

unless jQuery?.fn?.jquery
  console.error(_t("Annotator requires jQuery: have you included lib/vendor/jquery.js?"))

unless JSON and JSON.parse and JSON.stringify
  console.error(_t("Annotator requires a JSON implementation: have you included lib/vendor/json2.js?"))

$ = jQuery.sub();

$.flatten = (array) ->
  flatten = (ary) ->
    flat = []

    for el in ary
      flat = flat.concat(if el and $.isArray(el) then flatten(el) else el)

    return flat

  flatten(array)

# PluginFactory. Make a jQuery plugin out of a Class.
$.plugin = (name, object) ->
  # create a new plugin with the given name on the global jQuery object
  jQuery.fn[name] = (options) ->

    args = Array::slice.call(arguments, 1)
    this.each ->

      # check the data() cache, if it's there we'll call the method requested
      instance = $.data(this, name)
      if instance
        options && instance[options].apply(instance, args)
      else
        instance = new object(this, options)
        $.data(this, name, instance)

# Public: Finds all text nodes within the elements in the current collection.
#
# Returns a new jQuery collection of text nodes.
$.fn.textNodes = ->
  getTextNodes = (node) ->
    # textNode nodeType == 3
    if node and node.nodeType != 3
      nodes = []

      # If not a comment then traverse children collecting text nodes.
      # We traverse the child nodes manually rather than using the .childNodes
      # property because IE9 does not update the .childNodes property after
      # .splitText() is called on a child text node.
      if node.nodeType != 8
        # Start at the last child and walk backwards through siblings.
        node = node.lastChild
        while node
          nodes.push getTextNodes(node)
          node = node.previousSibling

      # Finally reverse the array so that nodes are in the correct order.
      return nodes.reverse()
    else
      return node

  this.map -> $.flatten(getTextNodes(this))

$.fn.xpath = (relativeRoot) ->
  jq = this.map ->
    path = ''
    elem = this

    # elementNode nodeType == 1
    while elem and elem.nodeType == 1 and elem isnt relativeRoot
      idx = $(elem.parentNode).children(elem.tagName).index(elem) + 1

      idx  =  if idx > 1 then "[#{idx}]" else ""
      path = "/" + elem.tagName.toLowerCase() + idx + path
      elem = elem.parentNode

    path

  jq.get()

$.escape = (html) ->
  html.replace(/&(?!\w+;)/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

$.fn.escape = (html) ->
  if arguments.length
    return this.html($.escape(html))

  this.html()