unless jQuery?.fn?.jquery
  console.error("Annotator requires jQuery: have you included lib/vendor/jquery.js?")

unless JSON and JSON.parse and JSON.stringify
  console.error("Annotator requires a JSON implementation: have you included lib/vendor/json2.js?")

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

$.fn.textNodes = ->
  getTextNodes = (node) ->
    # textNode nodeType == 3
    if node and node.nodeType != 3
      return (getTextNodes(n) for n in $(node).contents().get())
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

$.fn.escape = (html) ->
  if arguments.length
    return this.html(html.replace(/&(?!\w+;)/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'))

  this.html()
