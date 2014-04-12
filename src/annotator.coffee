extend = require('backbone-extend-standalone')

Delegator = require('./delegator')
Range = require('./range')
Util = require('./util')
Widget = require('./widget')
Viewer = require('./viewer')
Editor = require('./editor')
Notification = require('./notification')
Factory = require('./factory')
Plugin = require('./plugin')

AnnotationRegistry = require('./annotations')

# Core plugins
Adder = require('./plugin/adder')
Highlights = require('./plugin/highlights')
NullStore = require('./plugin/nullstore')

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

# Proxy events from the annotation registry
PROXY_EVENTS = {
  beforeCreate: 'beforeAnnotationCreated'
  create: 'annotationCreated'
  beforeUpdate: 'beforeAnnotationUpdated'
  update: 'annotationUpdated'
  beforeDelete: 'beforeAnnotationDeleted'
  delete: 'annotationDeleted'
  load: 'annotationsLoaded'
}

# Function returning a closure which should be called for a particular event
# from the annotation registry
proxyEventFor = (annotator, from) ->
  ->
    args = Array::slice.call(arguments)
    args.unshift(PROXY_EVENTS[from])
    annotator.trigger.apply(annotator, args)

class Annotator extends Delegator
  # Events to be bound on Annotator#element.
  events: {}
    #".annotator-hl mouseover": "onHighlightMouseover"
    #".annotator-hl mouseout": "startViewerHideTimer"

  options: # Configuration options
    # Start Annotator in read-only mode. No controls will be shown.
    readOnly: false

  plugins: {}

  editor: null

  viewer: null

  viewerHideTimer: null

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
      if not @options.readOnly
        factory.addPlugin(Adder, element)
      factory.addPlugin(Highlights, element)
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

    @annotations = new AnnotationRegistry()
    @annotations.configure(core: this)

    for from of PROXY_EVENTS
      this.listenTo(@annotations, from, proxyEventFor(this, from))

  # Public: attach the Annotator and its associated event handling to the
  # specified element.
  #
  # element - The element on which bind delegated events
  #
  # Returns the instance for chaining.
  attach: (element) ->
    @element = $(element)

    # Set up the core interface components
    #this._setupViewer()._setupEditor()
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

  # Creates an instance of Annotator.Viewer and assigns it to the @viewer
  # property, appends it to the @wrapper and sets up event listeners.
  #
  # Returns itself to allow chaining.
  _setupViewer: ->
    @viewer = new Annotator.Viewer(readOnly: @options.readOnly)
    @viewer.hide()
      .on("edit", this.onEditAnnotation)
      .on("delete", (annotation) =>
        @viewer.hide()
        this.publish('beforeAnnotationDeleted', [annotation])
        # Delete highlight elements.
        this.cleanupAnnotation(annotation)
        # Delete annotation
        this.annotations.delete(annotation)
          .done => this.publish('annotationDeleted', [annotation])
      )
      .addField({
        load: (field, annotation) =>
          if annotation.text
            $(field).html(Util.escape(annotation.text))
          else
            $(field).html("<i>#{_t 'No Comment'}</i>")
          this.publish('annotationViewerTextField', [field, annotation])
      })
      .element.appendTo(@wrapper).bind({
        "mouseover": this.clearViewerHideTimer
        "mouseout": this.startViewerHideTimer
      })
    this

  # Creates an instance of the Annotator.Editor and assigns it to @editor.
  # Appends this to the @wrapper and sets up event listeners.
  #
  # Returns itself for chaining.
  _setupEditor: ->
    @editor = new Annotator.Editor()
    @editor.hide()
      .on('hide', this.onEditorHide)
      .on('save', this.onEditorSubmit)
      .addField({
        type: 'textarea',
        label: _t('Comments') + '\u2026'
        load: (field, annotation) ->
          $(field).find('textarea').val(annotation.text || '')
        submit: (field, annotation) ->
          annotation.text = $(field).find('textarea').val()
      })

    @editor.element.appendTo(@wrapper)
    this

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

    @viewer.destroy()
    @editor.destroy()

    # coffeelint: disable=missing_fat_arrows
    @wrapper.find('.annotator-hl').each ->
      $(this).contents().insertBefore(this)
      $(this).remove()
    # coffeelint: enable=missing_fat_arrows

    @wrapper.contents().insertBefore(@wrapper)
    @wrapper.remove()
    @element.data('annotator', null)

    for plugin in @plugins
      plugin.destroy()

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
    @annotations._deprecatedDirectLoad(annotations)
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

  # Public: Waits for the @editor to submit or hide, returning a promise that
  # is resolved or rejected depending on whether the annotation was saved or
  # cancelled.
  editAnnotation: (annotation, position) ->
    dfd = $.Deferred()
    resolve = dfd.resolve.bind(dfd, annotation)
    reject = dfd.reject.bind(dfd, annotation)

    this.showEditor(annotation, position)
    this.subscribe('annotationEditorSubmit', resolve)
    this.once 'annotationEditorHidden', =>
      this.unsubscribe('annotationEditorSubmit', resolve)
      reject() if dfd.state() is 'pending'

    dfd.promise()

  # Public: Loads the @editor with the provided annotation and updates its
  # position in the window.
  #
  # annotation - An annotation to load into the editor.
  # location   - Position to set the Editor in the form {top: y, left: x}
  #
  # Examples
  #
  #   annotator.showEditor({text: "my comment"}, {top: 34, left: 234})
  #
  # Returns itself to allow chaining.
  showEditor: (annotation, location) =>
    @editor.element.css(location)
    @editor.load(annotation)
    this.publish('annotationEditorShown', [@editor, annotation])
    this

  # Callback method called when the @editor fires the "hide" event. Itself
  # publishes the 'annotationEditorHidden' event.
  #
  # Returns nothing.
  onEditorHide: =>
    this.publish('annotationEditorHidden', [@editor])

  # Callback method called when the @editor fires the "save" event. Itself
  # publishes the 'annotationEditorSubmit' event and creates/updates the
  # edited annotation.
  #
  # Returns nothing.
  onEditorSubmit: (annotation) =>
    this.publish('annotationEditorSubmit', [@editor, annotation])

  # Public: Loads the @viewer with an Array of annotations and positions it
  # at the location provided. Calls the 'annotationViewerShown' event.
  #
  # annotation - An Array of annotations to load into the viewer.
  # location   - Position to set the Viewer in the form {top: y, left: x}
  #
  # Examples
  #
  #   annotator.showViewer(
  #    [{text: "my comment"}, {text: "my other comment"}],
  #    {top: 34, left: 234})
  #   )
  #
  # Returns itself to allow chaining.
  showViewer: (annotations, location) =>
    @viewer.element.css(location)
    @viewer.load(annotations)

    this.publish('annotationViewerShown', [@viewer, annotations])

  # Annotator#element event callback. Allows 250ms for mouse pointer to get from
  # annotation highlight to @viewer to manipulate annotations. If timer expires
  # the @viewer is hidden.
  #
  # Returns nothing.
  startViewerHideTimer: =>
    # Don't do this if timer has already been set by another annotation.
    if not @viewerHideTimer
      @viewerHideTimer = setTimeout @viewer.hide, 250

  # Viewer#element event callback. Clears the timer set by
  # Annotator#startViewerHideTimer() when the @viewer is moused over.
  #
  # Returns nothing.
  clearViewerHideTimer: =>
    clearTimeout(@viewerHideTimer)
    @viewerHideTimer = false

  # Annotator#element callback. Displays viewer with all annotations
  # associated with highlight Elements under the cursor.
  #
  # event - A mouseover Event object.
  #
  # Returns nothing.
  onHighlightMouseover: (event) =>
    # Cancel any pending hiding of the viewer.
    this.clearViewerHideTimer()

    # Don't do anything if we're making a selection
    return false if @mouseIsDown

    # If the viewer is already shown, hide it first
    @viewer.hide() if @viewer.isShown()

    # coffeelint: disable=missing_fat_arrows
    annotations = $(event.target)
      .parents('.annotator-hl')
      .addBack()
      .map(-> return $(this).data("annotation"))
      .toArray()
    # coffeelint: enable=missing_fat_arrows

    # Now show the viewer with the wanted annotations
    this.showViewer(annotations, Util.mousePosition(event, @wrapper[0]))

  # Annotator#viewer callback function. Displays the Annotator#editor in the
  # positions of the Annotator#viewer and loads the passed annotation for
  # editing.
  #
  # annotation - An annotation Object for editing.
  #
  # Returns nothing.
  onEditAnnotation: (annotation) =>
    position = @viewer.element.position()
    @viewer.hide()

    $.when(annotation)

    .done (annotation) =>
      this.publish('beforeAnnotationUpdated', [annotation])

    .then (annotation) =>
      this.editAnnotation(annotation, position)
    .then (annotation) =>
      this.annotations.update(annotation)
        # Handle storage errors
        .fail(handleError)

    .done (annotation) =>
      this.publish('annotationUpdated', [annotation])


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
Annotator.Viewer = Viewer
Annotator.Editor = Editor
Annotator.Notification = Notification
Annotator.Plugin = Plugin

# Attach notification methods to the Annotation object
notification = new Notification()
Annotator.showNotification = notification.show
Annotator.hideNotification = notification.hide

# Register the default store
Annotator.Plugin.register('Adder', Adder)
Annotator.Plugin.register('Highlights', Highlights)
Annotator.Plugin.register('NullStore', NullStore)

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
