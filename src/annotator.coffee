$ = require('jquery')
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
NullStore = require('./nullstore')

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
  # Events to be bound on Annotator#element.
  events:
    ".annotator-adder button click": "onAdderClick"
    ".annotator-adder button mousedown": "onAdderMousedown"
    ".annotator-hl mouseover": "onHighlightMouseover"
    ".annotator-hl mouseout": "startViewerHideTimer"

  html:
    adder: '<div class="annotator-adder"><button type="button">' +
           _t('Annotate') +
           '</button></div>'
    wrapper: '<div class="annotator-wrapper"></div>'

  options: # Configuration options
    # Store plugin to use. If null, Annotator will use a default store.
    store: null
    # Start Annotator in read-only mode. No controls will be shown.
    readOnly: false
    # Initial query to load Annotations
    loadQuery: {}

  plugins: {}

  editor: null

  viewer: null

  selectedRanges: null

  mouseIsDown: false

  ignoreMouseup: false

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
      if @options.store
        factory.setStore(@options.store.type, @options.store)
      else
        factory.setStore(NullStore)
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
      for name, klass of Annotator.Plugin._ctors when p instanceof klass
        @plugins[name] = p

    @annotations = new AnnotationRegistry()
    @annotations.configure(core: this)


  # Public: attach the Annotator and its associated event handling to the
  # specified element.
  attach: (element) ->
    @element = $(element)
    this.addEvents()

    # Set up the core interface components
    this._setupDocumentEvents() unless @options.readOnly
    this._setupWrapper()._setupViewer()._setupEditor()
    this._setupDynamicStyle()

    # Create adder
    this.adder = $(this.html.adder).appendTo(@wrapper).hide()

    # Do initial load
    if @options.loadQuery then this.load(@options.loadQuery)

    for p in @plugins
      # TODO: Issue deprecation warning for plugins that use pluginInit
      p.annotator = this  # this must remain for backwards compatibility for as
                          # long as we support calling pluginInit
      p.pluginInit?()

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

  # Wraps the children of @element in a @wrapper div. NOTE: This method will
  # also remove any script elements inside @element to prevent them
  # re-executing.
  #
  # Returns itself to allow chaining.
  _setupWrapper: ->
    @wrapper = $(@html.wrapper)

    # We need to remove all scripts within the element before wrapping the
    # contents within a div. Otherwise when scripts are reappended to the DOM
    # they will re-execute. This is an issue for scripts that call
    # document.write() - such as ads - as they will clear the page.
    @element.find('script').remove()
    @element.wrapInner(@wrapper)
    @wrapper = @element.find('.annotator-wrapper')

    this

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

  # Sets up the selection event listeners to watch mouse actions on the
  # document.
  #
  # Returns itself for chaining.
  _setupDocumentEvents: ->
    $(document).bind({
      "mouseup": this.checkForEndSelection
      "mousedown": this.checkForStartSelection
    })
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

  # Public: Load and draw annotations from a given query.
  #
  # query - the query to pass to the backend
  #
  # Returns a Promise that resolves when loading is complete.
  load: (query) ->
    @annotations.query(query)
      .then (annotations, meta) =>
        this.loadAnnotations(annotations)

  # Public: Destroy the current Annotator instance, unbinding all events and
  # disposing of all relevant elements.
  #
  # Returns nothing.
  destroy: ->
    $(document).unbind({
      "mouseup": this.checkForEndSelection
      "mousedown": this.checkForStartSelection
    })

    $('#annotator-dynamic-style').remove()

    @adder.remove()
    @viewer.destroy()
    @editor.destroy()

    @wrapper.find('.annotator-hl').each ->
      $(this).contents().insertBefore(this)
      $(this).remove()

    @wrapper.contents().insertBefore(@wrapper)
    @wrapper.remove()
    @element.data('annotator', null)

    for plugin in @plugins
      plugin.destroy()

    this.removeEvents()
    idx = Annotator._instances.indexOf(this)
    if idx != -1
      Annotator._instances.splice(idx, 1)

  # Public: Gets the current selection excluding any nodes that fall outside of
  # the @wrapper. Then returns and Array of NormalizedRange instances.
  #
  # Examples
  #
  #   # A selection inside @wrapper
  #   annotation.getSelectedRanges()
  #   # => Returns [NormalizedRange]
  #
  #   # A selection outside of @wrapper
  #   annotation.getSelectedRanges()
  #   # => Returns []
  #
  # Returns Array of NormalizedRange instances.
  getSelectedRanges: ->
    selection = Util.getGlobal().getSelection()

    ranges = []
    rangesToIgnore = []
    unless selection.isCollapsed
      ranges = for i in [0...selection.rangeCount]
        r = selection.getRangeAt(i)
        browserRange = new Range.BrowserRange(r)
        normedRange = browserRange.normalize().limit(@wrapper[0])

        # If the new range falls fully outside the wrapper, we
        # should add it back to the document but not return it from
        # this method
        rangesToIgnore.push(r) if normedRange is null

        normedRange

      # BrowserRange#normalize() modifies the DOM structure and deselects the
      # underlying text as a result. So here we remove the selected ranges and
      # reapply the new ones.
      selection.removeAllRanges()

    for r in rangesToIgnore
      selection.addRange(r)

    # Remove any ranges that fell outside of @wrapper.
    $.grep ranges, (range) ->
      # Add the normed range back to the selection if it exists.
      selection.addRange(range.toRange()) if range
      range


  # Public: Initialises an annotation from an object representation. It finds
  # the selected range and higlights the selection in the DOM.
  #
  # annotation - An annotation Object to initialise.
  #
  # Examples
  #
  #   # Create a brand new annotation from the currently selected text.
  #   annotation = annotator.setupAnnotation({ranges: annotator.selectedRanges})
  #   # annotation has now been assigned the currently selected range
  #   # and a highlight appended to the DOM.
  #
  #   # Add an existing annotation that has been stored elsewere to the DOM.
  #   annotation = getStoredAnnotationWithSerializedRanges()
  #   annotation = annotator.setupAnnotation(annotation)
  #
  # Returns the initialised annotation.
  setupAnnotation: (annotation) ->
    root = @wrapper[0]

    normedRanges = []
    for r in annotation.ranges
      try
        normedRanges.push(Range.sniff(r).normalize(root))
      catch e
        if e instanceof Range.RangeError
          this.publish('rangeNormalizeFail', [annotation, r, e])
        else
          # Oh Javascript, why you so crap? This will lose the traceback.
          throw e

    annotation.quote      = []
    annotation.ranges     = []
    annotation._local = {}
    annotation._local.highlights = []

    for normed in normedRanges
      annotation.quote.push      $.trim(normed.text())
      annotation.ranges.push     normed.serialize(@wrapper[0], '.annotator-hl')
      $.merge annotation._local.highlights, this.highlightRange(normed)

    # Join all the quotes into one string.
    annotation.quote = annotation.quote.join(' / ')

    # Save the annotation data on each highlighter element.
    $(annotation._local.highlights).data('annotation', annotation)

    annotation

  # Public: Deletes the annotation by removing the highlight from the DOM.
  #
  # annotation - An annotation Object to delete.
  #
  # Returns deleted annotation.
  cleanupAnnotation: (annotation) ->
    if annotation._local?.highlights?
      for h in annotation._local.highlights when h.parentNode?
        $(h).replaceWith(h.childNodes)
      delete annotation._local.highlights

    annotation

  # Public: Loads an Array of annotations into the @element. Breaks the task
  # into chunks of 10 annotations.
  #
  # annotations - An Array of annotation Objects.
  #
  # Examples
  #
  #   loadAnnotationsFromStore (annotations) ->
  #     annotator.loadAnnotations(annotations)
  #
  # Returns itself for chaining.
  loadAnnotations: (annotations = []) ->
    loader = (annList = []) =>
      now = annList.splice(0,10)

      for n in now
        this.setupAnnotation(n)

      # If there are more to do, do them after a 10ms break (for browser
      # responsiveness).
      if annList.length > 0
        setTimeout((-> loader(annList)), 10)
      else
        this.publish 'annotationsLoaded', [clone]

    clone = annotations.slice()
    loader annotations

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

  # Public: Wraps the DOM Nodes within the provided range with a highlight
  # element of the specified class and returns the highlight Elements.
  #
  # normedRange - A NormalizedRange to be highlighted.
  # cssClass - A CSS class to use for the highlight (default: 'annotator-hl')
  #
  # Returns an array of highlight Elements.
  highlightRange: (normedRange, cssClass = 'annotator-hl') ->
    white = /^\s*$/

    hl = $("<span class='#{cssClass}'></span>")

    # Ignore text nodes that contain only whitespace characters. This prevents
    # spans being injected between elements that can only contain a restricted
    # subset of nodes such as table rows and lists. This does mean that there
    # may be the odd abandoned whitespace node in a paragraph that is skipped
    # but better than breaking table layouts.
    for node in normedRange.textNodes() when not white.test(node.nodeValue)
      $(node).wrapAll(hl).parent().show()[0]

  # Public: highlight a list of ranges
  #
  # normedRanges - An array of NormalizedRanges to be highlighted.
  # cssClass - A CSS class to use for the highlight (default: 'annotator-hl')
  #
  # Returns an array of highlight Elements.
  highlightRanges: (normedRanges, cssClass = 'annotator-hl') ->
    highlights = []
    for r in normedRanges
      $.merge highlights, this.highlightRange(r, cssClass)
    highlights

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
  # publishes the 'annotationEditorHidden' event and resets the @ignoreMouseup
  # property to allow listening to mouse events.
  #
  # Returns nothing.
  onEditorHide: =>
    this.publish('annotationEditorHidden', [@editor])
    @ignoreMouseup = false

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

  # Annotator#element callback. Sets the @mouseIsDown property used to
  # determine if a selection may have started to true. Also calls
  # Annotator#startViewerHideTimer() to hide the Annotator#viewer.
  #
  # event - A mousedown Event object.
  #
  # Returns nothing.
  checkForStartSelection: (event) =>
    unless event and this.isAnnotator(event.target)
      this.startViewerHideTimer()
    @mouseIsDown = true

  # Annotator#element callback. Checks to see if a selection has been made
  # on mouseup and if so displays the Annotator#adder. If @ignoreMouseup is
  # set will do nothing. Also resets the @mouseIsDown property.
  #
  # event - A mouseup Event object.
  #
  # Returns nothing.
  checkForEndSelection: (event) =>
    @mouseIsDown = false

    # This prevents the note image from jumping away on the mouseup
    # of a click on icon.
    if @ignoreMouseup
      return

    # Get the currently selected ranges.
    @selectedRanges = this.getSelectedRanges()

    for range in @selectedRanges
      container = range.commonAncestor
      if $(container).hasClass('annotator-hl')
        container = $(container).parents('[class!=annotator-hl]')[0]
      return if this.isAnnotator(container)

    if event and @selectedRanges.length
      @adder
        .css(Util.mousePosition(event, @wrapper[0]))
        .show()
    else
      @adder.hide()

  # Public: Determines if the provided element is part of the annotator plugin.
  # Useful for ignoring mouse actions on the annotator elements.
  # NOTE: The @wrapper is not included in this check.
  #
  # element - An Element or TextNode to check.
  #
  # Examples
  #
  #   span = document.createElement('span')
  #   annotator.isAnnotator(span) # => Returns false
  #
  #   annotator.isAnnotator(annotator.viewer.element) # => Returns true
  #
  # Returns true if the element is a child of an annotator element.
  isAnnotator: (element) ->
    !!$(element)
      .parents()
      .addBack()
      .filter('[class^=annotator-]')
      .not(@wrapper)
      .length


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

    annotations = $(event.target)
      .parents('.annotator-hl')
      .addBack()
      .map(-> return $(this).data("annotation"))
      .toArray()

    # Now show the viewer with the wanted annotations
    this.showViewer(annotations, Util.mousePosition(event, @wrapper[0]))

  # Annotator#element callback. Sets @ignoreMouseup to true to prevent
  # the annotation selection events firing when the adder is clicked.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  onAdderMousedown: (event) =>
    event?.preventDefault()
    @ignoreMouseup = true

  # Annotator#element callback. Displays the @editor in place of the @adder and
  # loads in a newly created annotation Object. The click event is used as well
  # as the mousedown so that we get the :active state on the @adder when clicked
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  onAdderClick: (event) =>
    event?.preventDefault()

    # Hide the adder
    position = @adder.position()
    @adder.hide()
    annotation = {ranges: @selectedRanges}

    $.when(annotation)

    .done (annotation) =>
      this.publish('beforeAnnotationCreated', [annotation])

    # Set up the annotation
    .then (annotation) =>
      this.setupAnnotation(annotation)

    # Show a temporary highlight so the user can see what they selected
    .done (annotation) ->
      $(annotation._local.highlights).addClass('annotator-hl-temporary')

    # Edit the annotation
    .then (annotation) =>
      this.editAnnotation(annotation, position)
    .then (annotation) =>
      this.annotations.create(annotation)
        # Handle storage errors
        .fail(handleError)

    # Clean up the highlights
    .done (annotation) ->
      $(annotation._local.highlights).removeClass('annotator-hl-temporary')

    .done (annotation) =>
      this.publish('annotationCreated', [annotation])

    # Clean up (if, for example, editing was cancelled, or storage failed)
    .fail(this.cleanupAnnotation)

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
