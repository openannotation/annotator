$ = require('jquery')
Promise = require('es6-promise').Promise


# FIXME: Consolidate checks of this sort into one place
unless JSON and JSON.parse and JSON.stringify
  console.error(gettext("Annotator requires a JSON implementation: have you
                         included lib/vendor/json2.js?"))


ESCAPE_MAP = {
  "&": "&amp;"
  "<": "&lt;"
  ">": "&gt;"
  '"': "&quot;"
  "'": "&#39;"
  "/": "&#47;"
}

# escapeHtml sanitizes special characters in text that could be interpreted as
# HTML.
escapeHtml = (string) ->
  return String(string).replace(/[&<>"'\/]/g, (c) ->
    return ESCAPE_MAP[c]
  )


# I18N
gettext = (msgid) -> msgid

if Gettext?
  _gettext = new Gettext(domain: "annotator")
  gettext = (msgid) -> _gettext.gettext(msgid)


# getGlobal returns the global object (window in a browser, the global namespace
# object in Node, etc.)
getGlobal = -> (-> this)()


# Returns the absolute position of the mouse relative to the top-left rendered
# corner of the page (taking into account padding/margin/border on the body
# element as necessary).
mousePosition = (event) ->
  offset = $(getGlobal().document.body).offset()
  {
    top: event.pageY - offset.top,
    left: event.pageX - offset.left,
  }


exports.$ = $
exports.Promise = Promise
exports.TranslationString = gettext
exports.escapeHtml = escapeHtml
exports.getGlobal = getGlobal
exports.mousePosition = mousePosition
