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
    if node and node.nodeType != Node.TEXT_NODE
      nodes = []

      # If not a comment then traverse children collecting text nodes.
      # We traverse the child nodes manually rather than using the .childNodes
      # property because IE9 does not update the .childNodes property after
      # .splitText() is called on a child text node.
      if node.nodeType != Node.COMMENT_NODE
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
  try
    result = simpleXPathJQuery.call this, relativeRoot
  catch exception
    console.log "jQuery-based XPath construction failed! Falling back to manual."
    result = simpleXPathPure.call this, relativeRoot
  result

$.xpath = (xp, root) ->
  steps = xp.substring(1).split("/")
  node = root
  for step in steps
    [name, idx] = step.split "["
    idx = if idx? then parseInt (idx?.split "]")[0] else 1
    node = findChild node, name.toLowerCase(), idx

  node

$.escape = (html) ->
  html.replace(/&(?!\w+;)/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

$.fn.escape = (html) ->
  if arguments.length
    return this.html($.escape(html))

  this.html()

# Create a jQuery reverse function, but watch out for prototype.js
$.fn.reverse = []._reverse or [].reverse
