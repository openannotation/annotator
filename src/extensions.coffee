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

$.fn.xpath1 = (relativeRoot) ->
  jq = this.map ->
    path = ''
    elem = this

    # elementNode nodeType == 1
    while elem and elem.nodeType == 1 and elem isnt relativeRoot
      tagName = elem.tagName.replace(":", "\\:").replace("=", "\\=")
      idx = $(elem.parentNode).children(tagName).index(elem) + 1
      idx  = "[#{idx}]"
      path = "/" + elem.tagName.toLowerCase() + idx + path
      elem = elem.parentNode

    path

  jq.get()

$.getProperNodeName = (node) ->
    nodeName = node.nodeName.toLowerCase()
    switch nodeName
      when "#text" then return "text()"
      when "#comment" then return "comment()"
      when "#cdata-section" then return "cdata-section()"
      else return nodeName

$.fn.xpath2 = (relativeRoot) ->

  getNodePosition = (node) ->
    pos = 0
    tmp = node
    while tmp
      if tmp.nodeName is node.nodeName
        pos++
      tmp = tmp.previousSibling
    pos

  getPathSegment = (node) ->
    name = $.getProperNodeName node
    pos = getNodePosition node
    name + (if pos > 1 then "[#{pos}]" else "")

  rootNode = relativeRoot

  getPathTo = (node) ->
    xpath = '';
    while node != rootNode
      unless node?
        throw new Error "Called getPathTo on a node which was not a descendant of @rootNode. " + rootNode
      xpath = (getPathSegment node) + '/' + xpath
      node = node.parentNode
    xpath = '/' + xpath
    xpath = xpath.replace /\/$/, ''
    xpath        

  jq = this.map ->
    path = getPathTo this

    path

  jq.get()

$.fn.xpath = (relativeRoot) ->
  try
    result = this.xpath1 relativeRoot
  catch exception
    console.log "jQuery-based XPath construction failed! Falling back to manual."
    result = this.xpath2 relativeRoot
  result

$.findChild = (node, type, index) ->
  unless node.hasChildNodes()
    throw new Error "XPath error: node has no children!"
  children = node.childNodes
  found = 0
  for child in children
    name = $.getProperNodeName child
    if name is type
      found += 1
      if found is index
        return child
  throw new Error "XPath error: wanted child not found."
  

$.dummyXPathEvaluate = (xp, root) ->
  steps = xp.substring(1).split("/")
  node = root
  for step in steps
    [name, idx] = step.split "["
    idx = if idx? then parseInt (idx?.split "]")[0] else 1
    node = $.findChild node, name.toLowerCase(), idx

  node

$.escape = (html) ->
  html.replace(/&(?!\w+;)/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

$.fn.escape = (html) ->
  if arguments.length
    return this.html($.escape(html))

  this.html()

# Create a jQuery reverse function, but watch out for prototype.js
$.fn.reverse = []._reverse or [].reverse
