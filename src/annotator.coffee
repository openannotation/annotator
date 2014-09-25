core = require('./core')

Util = require('./util')

NullStore = require('./nullstore').NullStore
DefaultUI = require('./plugin/defaultui').DefaultUI

$ = Util.$
_t = Util.TranslationString

# Store a reference to the current Annotator object.
_Annotator = this.Annotator

handleError = ->
  console.error.apply(console, arguments)


# Annotator represents a sane default configuration of AnnotatorCore, with a
# default set of plugins and a user interface.
class Annotator extends core.AnnotatorCore

  # Public: Creates an instance of the Annotator.
  #
  # NOTE: If the Annotator is not supported by the current browser it will not
  # perform any setup and simply return a basic object. This allows plugins
  # to still be loaded but will not function as expected. It is reccomended
  # to call Annotator.supported() before creating the instance or using the
  # Unsupported plugin which will notify users that the Annotator will not work.
  #
  # element - A DOM Element in which to annotate.
  # options - An options Object.
  #
  # Examples
  #
  #   annotator = new Annotator(document.body)
  #
  #   # Example of checking for support.
  #   if Annotator.supported()
  #     annotator = new Annotator(document.body)
  #   else
  #     # Fallback for unsupported browsers.
  #
  # Returns a new instance of the Annotator.
  constructor: (element, options) ->
    super

    @element = element
    @options = options

    Annotator._instances.push(this)

    # Return early if the annotator is not supported.
    return this unless Annotator.supported()

    this.setStorage(NullStore)
    this.addPlugin(DefaultUI(element))

    this._setupDynamicStyle()

  # Sets up any dynamically calculated CSS for the Annotator.
  #
  # Returns the instance for chaining.
  _setupDynamicStyle: ->
    $('#annotator-dynamic-style').remove()

    notclasses = ['adder', 'outer', 'notice', 'filter']
    sel = '*' + (":not(.annotator-#{x})" for x in notclasses).join('')

    # use the maximum z-index in the page
    max = Util.maxZIndex($(document.body).find(sel))

    # but don't go smaller than 1010, because this isn't bulletproof --
    # dynamic elements in the page (notifications, dialogs, etc.) may well
    # have high z-indices that we can't catch using the above method.
    max = Math.max(max, 1000)

    rules = [
      ".annotator-adder, .annotator-outer, .annotator-notice {"
      "  z-index: #{max + 20};"
      "}"
      ".annotator-filter {"
      "  z-index: #{max + 10};"
      "}"
    ].join("\n")

    style = $('<style>' + rules + '</style>')
              .attr('id', 'annotator-dynamic-style')
              .attr('type', 'text/css')
              .appendTo('head')

    this

  # Public: Destroy the current Annotator instance, unbinding all events and
  # disposing of all relevant elements.
  #
  # Returns nothing.
  destroy: ->
    super

    $('#annotator-dynamic-style').remove()

    idx = Annotator._instances.indexOf(this)
    if idx != -1
      Annotator._instances.splice(idx, 1)


# Sniff the browser environment and attempt to add missing functionality.
g = Util.getGlobal()

# Checks for the presence of wicked-good-xpath
# It is always safe to install it, it'll not overwrite existing functions
if g.wgxpath? then g.wgxpath.install()

if not g.getSelection?
  $.getScript('http://assets.annotateit.org/vendor/ierange.min.js')

if not g.JSON?
  $.getScript('http://assets.annotateit.org/vendor/json2.min.js')

# Ensure the Node constants are defined
if not g.Node?
  g.Node =
    ELEMENT_NODE: 1
    ATTRIBUTE_NODE: 2
    TEXT_NODE: 3
    CDATA_SECTION_NODE: 4
    ENTITY_REFERENCE_NODE: 5
    ENTITY_NODE: 6
    PROCESSING_INSTRUCTION_NODE: 7
    COMMENT_NODE: 8
    DOCUMENT_NODE: 9
    DOCUMENT_TYPE_NODE: 10
    DOCUMENT_FRAGMENT_NODE: 11
    NOTATION_NODE: 12

# Create namespace object for core-provided plugins
Annotator.Plugin = {}

# Export other modules for use in plugins.
Annotator.Core = core.AnnotatorCore
Annotator.Delegator = require('./delegator')
Annotator.Notification = require('./notification')
Annotator.Util = Util

# Attach notification methods to the Annotation object
notification = new Annotator.Notification()
Annotator.showNotification = notification.show
Annotator.hideNotification = notification.hide

# Expose a global instance registry
Annotator._instances = []

# Bind gettext helper so plugins can use localisation.
Annotator._t = _t

# Returns true if the Annotator can be used in the current browser.
Annotator.supported = -> Util.getGlobal().getSelection?

# Restores the Annotator property on the global object to it's
# previous value and returns the Annotator.
Annotator.noConflict = ->
  Util.getGlobal().Annotator = _Annotator
  return Annotator

# Export Annotator object.
module.exports = Annotator
