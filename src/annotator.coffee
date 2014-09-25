Core = require('./core')
Util = require('./util')

Storage = require('./storage')
DefaultUI = require('./plugin/defaultui').DefaultUI

# Store a reference to the current Annotator object.
_Annotator = this.Annotator


# Annotator represents a sane default configuration of AnnotatorCore, with a
# default set of plugins and a user interface.
class Annotator extends Core.AnnotatorCore

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

    Annotator._instances.push(this)

    # Return early if the annotator is not supported.
    return this unless Annotator.supported()

    this.setStorage(Storage.NullStorage)
    this.addPlugin(DefaultUI(element, options))

  # Public: Destroy the current Annotator instance, unbinding all events and
  # disposing of all relevant elements.
  #
  # Returns nothing.
  destroy: ->
    super

    idx = Annotator._instances.indexOf(this)
    if idx != -1
      Annotator._instances.splice(idx, 1)


# Sniff the browser environment and attempt to add missing functionality.
g = Util.getGlobal()

# Checks for the presence of wicked-good-xpath
# It is always safe to install it, it'll not overwrite existing functions
if g.wgxpath? then g.wgxpath.install()

if not g.getSelection?
  Util.$.getScript('http://assets.annotateit.org/vendor/ierange.min.js')

if not g.JSON?
  Util.$.getScript('http://assets.annotateit.org/vendor/json2.min.js')

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
Annotator.Core = Core
Annotator.Delegator = require('./delegator')
Annotator.Notification = require('./notification')
Annotator.Storage = Storage
Annotator.Util = Util

# Attach notification methods to the Annotation object
notification = new Annotator.Notification()
Annotator.showNotification = notification.show
Annotator.hideNotification = notification.hide

# Expose a global instance registry
Annotator._instances = []

# Bind gettext helper so plugins can use localisation.
Annotator._t = Util.TranslationString

# Returns true if the Annotator can be used in the current browser.
Annotator.supported = -> Util.getGlobal().getSelection?

# Restores the Annotator property on the global object to it's
# previous value and returns the Annotator.
Annotator.noConflict = ->
  Util.getGlobal().Annotator = _Annotator
  return Annotator

# Export Annotator object.
module.exports = Annotator
