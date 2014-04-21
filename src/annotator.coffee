extend = require('backbone-extend-standalone')

Delegator = require('./delegator')
Range = require('./range')
Util = require('./util')
Widget = require('./widget')
Notification = require('./notification')
Factory = require('./factory')
Plugin = require('./plugin')

AnnotationRegistry = require('./annotations')

# Core plugins
Adder = require('./plugin/adder')
Editor = require('./plugin/editor')
Highlighter = require('./plugin/highlighter')
NullStore = require('./plugin/nullstore')
Viewer = require('./plugin/viewer')

$ = Util.$
_t = Util.TranslationString

# Selection and range creation reference for the following code:
# http://www.quirksmode.org/dom/range_intro.html
#
# I've removed any support for IE TextRange (see commit d7085bf2 for code)
# for the moment, having no means of testing it.

# Store a reference to the current Annotator object.
_Annotator = this.Annotator

handleError = ->
  console.error.apply(console, arguments)


class Annotator extends Delegator
  options: # Configuration options
    # Start Annotator in read-only mode. No controls will be shown.
    readOnly: false

  plugins: {}

  # Public: Creates an instance of the Annotator.
  #
  # Legacy signature: In Annotator v1.2.x this element required a DOM Element on
  # which to watch for annotations as well as any options. This is no longer
  # required and may eventually be deprecated.
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
    @options = $.extend(true, {}, @options, options)
    @plugins = {}

    Annotator._instances.push(this)

    # Check for old-style plugin bindings and issue deprecation warnings
    Annotator.Plugin._rebindOldPlugins()

    # Return early if the annotator is not supported.
    return this unless Annotator.supported()

    if element
      # If element is supplied, then we are operating in legacy mode, rather
      # than being created by a Factory instance. Create the Factory ourselves
      # and use it to bootstrap.
      factory = new Factory()
      factory.setStore(NullStore)
      factory.addPlugin(Highlighter, element)
      factory.addPlugin(Viewer, element, {
        showEditButton: not @options.readOnly,
        showDeleteButton: not @options.readOnly,
      })
      if not @options.readOnly
        factory.addPlugin(Adder, element)
        factory.addPlugin(Editor)
      factory.configureInstance(this)

      this.attach(element)

  # Configure the Annotator. Typically called by an Annotator.Factory, or the
  # constructor when operating in legacy (v1) mode.
  configure: (config) ->
    {@store, plugins} = config
    @plugins = {}

    # TODO: Stop using this hash to find plugins
    # This block is super hacky and dumb.
    for p in plugins
      for name, klass of Annotator.Plugin._ctors
        if p.constructor is klass
          @plugins[name] = p
          break

    @annotations = new AnnotationRegistry(this, @store)

  # Public: attach the Annotator and its associated event handling to the
  # specified element.
  #
  # element - The element on which bind delegated events
  #
  # Returns the instance for chaining.
  attach: (element) ->
    @element = $(element)

    # Set up the core interface components
    this._setupDynamicStyle()

    for name of @plugins
      p = @plugins[name]
      # TODO: Issue deprecation warning for plugins that use pluginInit
      p.annotator = this  # this must remain for backwards compatibility for as
                          # long as we support calling pluginInit
      p.pluginInit?()

    # Return this for chaining
    this

  # Public: Creates a subclass of Annotator.
  #
  # See the documentation from Backbone: http://backbonejs.org/#Model-extend
  #
  # Examples
  #
  #   var ExtendedAnnotator = Annotator.extend({
  #     setupAnnotation: function (annotation) {
  #       // Invoke the built-in implementation
  #       try {
  #         Annotator.prototype.setupAnnotation.call(this, annotation);
  #       } catch (e) {
  #         if (e instanceof Annotator.Range.RangeError) {
  #           // Try to locate the Annotation using the quote
  #         } else {
  #           throw e;
  #         }
  #       }
  #
  #       return annotation;
  #   });
  #
  #   var annotator = new ExtendedAnnotator(document.body, /* {options} */);
  @extend: extend

  # Sets up any dynamically calculated CSS for the Annotator.
  #
  # Returns itself for chaining.
  _setupDynamicStyle: ->
    style = $('#annotator-dynamic-style')

    if (!style.length)
      style = $('<style id="annotator-dynamic-style"></style>')
                .appendTo(document.head)

    notclasses = ['adder', 'outer', 'notice', 'filter']
    sel = '*' + (":not(.annotator-#{x})" for x in notclasses).join('')

    # use the maximum z-index in the page
    max = Util.maxZIndex($(document.body).find(sel))

    # but don't go smaller than 1010, because this isn't bulletproof --
    # dynamic elements in the page (notifications, dialogs, etc.) may well
    # have high z-indices that we can't catch using the above method.
    max = Math.max(max, 1000)

    style.text [
      ".annotator-adder, .annotator-outer, .annotator-notice {"
      "  z-index: #{max + 20};"
      "}"
      ".annotator-filter {"
      "  z-index: #{max + 10};"
      "}"
    ].join("\n")

    this


  # Public: Destroy the current Annotator instance, unbinding all events and
  # disposing of all relevant elements.
  #
  # Returns nothing.
  destroy: ->
    $('#annotator-dynamic-style').remove()

    for name, plugin of @plugins
      plugin.destroy?()

    this.removeEvents()
    idx = Annotator._instances.indexOf(this)
    if idx != -1
      Annotator._instances.splice(idx, 1)


  # Public: Loads an Array of annotations objects.
  #
  # annotations - An Array of annotation Objects.
  #
  # Examples
  #
  #   loadAnnotationsFromStore (annotations) ->
  #     annotator.loadAnnotations(annotations)
  #
  # @slatedForDeprecation 2.1.0
  #
  # Returns itself for chaining.
  loadAnnotations: (annotations = []) ->
    Util.deprecationWarning("Annotator#loadAnnotations is deprecated and will be
                             removed in a future version of Annotator. Please
                             implement your own store plugin with an appropriate
                             query method if you wish to implement direct
                             loading of annotations in the page.")

    this.trigger('loadAnnotations', annotations, null) # null meta object
    this

  # Public: Calls the Store#dumpAnnotations() method.
  #
  # Returns dumped annotations Array or false if Store is not loaded.
  dumpAnnotations: ->
    if @store?.dumpAnnotations?
      @store.dumpAnnotations()
    else
      console.warn(_t("Can't dump annotations without store plugin."))
      return false

  # Public: Registers a plugin with the Annotator. A plugin can only be
  # registered once. The plugin will be instantiated in the following order.
  #
  # 1. A new instance of the plugin will be created (providing the @element and
  #    options as params) then assigned to the @plugins registry.
  # 2. The current Annotator instance will be attached to the plugin.
  # 3. The Plugin#pluginInit() method will be called if it exists.
  #
  # name    - Plugin to instantiate. Must be in the Annotator.Plugins namespace.
  # options - Any options to be provided to the plugin constructor.
  #
  # Examples
  #
  #   annotator
  #     .addPlugin('Tags')
  #     .addPlugin('Store', {
  #       prefix: '/store'
  #     })
  #     .addPlugin('Permissions', {
  #       user: 'Bill'
  #     })
  #
  # Returns itself to allow chaining.
  addPlugin: (name, options) ->
    # TODO: Add a deprecation warning

    klass = Annotator.Plugin.fetch(name)
    if typeof klass is 'function'
      plug = new klass(@element[0], options)
      plug.annotator = this
      plug.pluginInit?()
      @plugins[name] = plug
    else
      console.error(
        _t("Could not load ") +
        name +
        _t(" plugin. Have you included the appropriate <script> tag?")
      )

    this # allow chaining

# An Annotator Factory with the core constructor defaulted to Annotator
class Annotator.Factory extends Factory
  constructor: (core = Annotator) ->
    super core
    this.setStore(NullStore)

# Sniff the browser environment and attempt to add missing functionality.
g = Util.getGlobal()

if not g.document?.evaluate?
  $.getScript('http://assets.annotateit.org/vendor/xpath.min.js')

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


# Export other modules for use in plugins.
Annotator.Delegator = Delegator
Annotator.Range = Range
Annotator.Util = Util
Annotator.Widget = Widget
Annotator.Notification = Notification
Annotator.Plugin = Plugin

# Attach notification methods to the Annotation object
notification = new Notification()
Annotator.showNotification = notification.show
Annotator.hideNotification = notification.hide

# Register the default store
Annotator.Plugin.register('Adder', Adder)
Annotator.Plugin.register('Editor', Editor)
Annotator.Plugin.register('Highlighter', Highlighter)
Annotator.Plugin.register('NullStore', NullStore)
Annotator.Plugin.register('Viewer', Viewer)

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
