$ = require('jquery')
Promise = require('es6-promise').Promise


# FIXME: Consolidate checks of this sort into one place
unless JSON and JSON.parse and JSON.stringify
  console.error(gettext("Annotator requires a JSON implementation: have you
                         included lib/vendor/json2.js?"))


# isArray returns a boolean indicating whether the passed object is an Array.
#
# NB: This is tricky to get right. See the following for details:
#
#   http://perfectionkills.com/instanceof-considered-harmful-or-how-to-write-a-robust-isarray/
#
# Returns a boolean.
isArray = (o) ->
  return Object.prototype.toString.call(o) == '[object Array]'


# contains returns a boolean indicating whether node A is an ancestor of node B.
#
# This function purposefully ignores the native browser function for this,
# because it acts weird in PhantomJS (See
# https://github.com/ariya/phantomjs/issues/11479).
#
# Returns a boolean
contains = (parent, child) ->
  node = child
  while node?
    if node is parent then return true
    node = node.parentNode
  return false


# escape sanitizes special characters in text that could be interpreted as HTML.
escape = (html) ->
  html
    .replace(/&(?!\w+;)/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')


# flatten turns a nested array structure into a single flat array.
#
# Returns an array.
flatten = (array) ->
  flat = []

  for el in array
    flat = flat.concat(if isArray(el) then flatten(el) else el)

  return flat


# I18N
gettext = (msgid) -> msgid

if Gettext?
  _gettext = new Gettext(domain: "annotator")
  gettext = (msgid) -> _gettext.gettext(msgid)


# getGlobal returns the global object (window in a browser, the global namespace
# object in Node, etc.)
getGlobal = -> (-> this)()


# Return the maximum z-index of any element in $elements (a jQuery collection).
maxZIndex = ($elements) ->
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
mousePosition = (event) ->
  offset = $(getGlobal().document.body).offset()
  {
    top: event.pageY - offset.top,
    left: event.pageX - offset.left,
  }


# uuid returns an integer that is unique within the current session.
uuid = (-> counter = -1; -> counter += 1)()


exports.$ = $
exports.Promise = Promise
exports.TranslationString = gettext
exports.contains = contains
exports.escape = escape
exports.flatten = flatten
exports.getGlobal = getGlobal
exports.maxZIndex = maxZIndex
exports.mousePosition = mousePosition
exports.uuid = uuid
