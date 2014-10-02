$ = require('jquery')
Promise = require('es6-promise').Promise


# I18N
gettext = null

if Gettext?
  _gettext = new Gettext(domain: "annotator")
  gettext = (msgid) -> _gettext.gettext(msgid)
else
  gettext = (msgid) -> msgid

_t = (msgid) -> gettext(msgid)

unless JSON and JSON.parse and JSON.stringify
  console.error(_t("Annotator requires a JSON implementation: have you included
                    lib/vendor/json2.js?"))

Util = {}

# Enable CORS support for Ajax
$.support.cors = true

# Provide access to our copy of jQuery
Util.$ = $

# Provide a Promise implementation
Util.Promise = Promise

# Public: Create a Gettext translated string from a message id
#
# Returns a String
Util.TranslationString = _t

# Send a deprecation warning to the console
Util.deprecationWarning = (args...) ->
  console.warn("Annotator DeprecationWarning:", args...)

# Public: Flatten a nested array structure
#
# Returns an array
Util.flatten = (array) ->
  flatten = (ary) ->
    flat = []

    for el in ary
      flat = flat.concat(if el and $.isArray(el) then flatten(el) else el)

    return flat

  flatten(array)


# Public: decides whether node A is an ancestor of node B.
#
# This function purposefully ignores the native browser function for this,
# because it acts weird in PhantomJS.
# Issue: https://github.com/ariya/phantomjs/issues/11479
Util.contains = (parent, child) ->
  node = child
  while node?
    if node is parent then return true
    node = node.parentNode
  return false


Util.escape = (html) ->
  html
    .replace(/&(?!\w+;)/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')

Util.uuid = (-> counter = -1; -> counter += 1)()

Util.getGlobal = -> (-> this)()

# Return the maximum z-index of any element in $elements (a jQuery collection).
Util.maxZIndex = ($elements) ->
  all = for el in $elements
    if $(el).css('position') == 'static'
      -1
    else
      # Use parseFloat since we may get scientific notation for large values.
      parseFloat($(el).css('z-index')) or -1
  Math.max.apply(Math, all)

# Returns the absolute position of the mouse relative to the top-left rendered
# corner of the page (taking into account padding/margin/border on the body
# element as necessary).
Util.mousePosition = (event) ->
  offset = $(Util.getGlobal().document.body).offset()
  {
    top: event.pageY - offset.top,
    left: event.pageX - offset.left,
  }

# Checks to see if an event parameter is provided and contains the prevent
# default method. If it does it calls it.
#
# This is useful for methods that can be optionally used as callbacks
# where the existance of the parameter must be checked before calling.
Util.preventEventDefault = (event) ->
  event?.preventDefault?()


# Export Util object
module.exports = Util
