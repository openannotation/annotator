# Selection and range creation reference for the following code:
# http://www.quirksmode.org/dom/range_intro.html
#
# I've removed any support for IE TextRange (see commit d7085bf2 for code)
# for the moment, having no means of testing it.

util =
  getGlobal: -> (-> this)()

  mousePosition: (e, offsetEl) ->
    offset = $(offsetEl).offset()
    {
      top:  e.pageY - offset.top,
      left: e.pageX - offset.left
    }

class Annotator extends Delegator
  events:
    ".annotator-adder click":     "onAdderClick"
    ".annotator-adder mousedown": "onAdderMousedown"
    ".annotator-hl mouseover":    "onHighlightMouseover"
    ".annotator-hl mouseout":     "startViewerHideTimer"

    # TODO: allow for adding these events on document.body
    "mouseup":   "checkForEndSelection"
    "mousedown": "checkForStartSelection"

  html:
    hl:     "<span class='annotator-hl'></span>"
    adder:  "<div class='annotator-adder'><a href='#'></a></div>"

  options: {} # Configuration options

  plugins: {}

  constructor: (element, options) ->
    # Return early if the annotator is not supported.
    return this unless Annotator.supported()

    super
    element = $(@element)

    # Wrap element contents
    @wrapper = $("<div></div>").addClass('annotator-wrapper')
    
    # We need to remove all scripts within the element before wrapping the
    # contents within a div. Otherwise when scripts are reappended to the DOM
    # they will re-execute. This is an issue for scripts that call
    # document.write() - such as ads - as they will clear the page.
    element.find('script').remove()

    element.wrapInner(@wrapper)
    @wrapper = $(@element).contents().get(0)

    # Set up the annotation editor
    @editor = new Annotator.Editor()
    @editor.hide()
    $(@editor.element)
      .appendTo(@wrapper)
      .bind('hide', this.onEditorHide)
      .bind('save', this.onEditorSubmit)

    @viewer = new Annotator.Viewer()
    @viewer.hide()
    $(@viewer.element).appendTo(@wrapper).bind({
      "edit":      this.onEditAnnotation
      "delete":    this.onDeleteAnnotation
      "mouseover": this.clearViewerHideTimer
      "mouseout":  this.startViewerHideTimer
    })

    # Create model dom elements
    for name, src of @html
      this[name] = $(src).appendTo(@wrapper).hide()

  getSelection: ->
    @selection = util.getGlobal().getSelection()
    @selectedRanges = (@selection.getRangeAt(i) for i in [0...@selection.rangeCount])

  createNewAnnotation: () ->
    annotation = {}
    $(@element).trigger('beforeAnnotationCreated', [annotation])
    annotation

  createAnnotation: (annotation, fireEvents=true) ->
    a = annotation

    a or= {}
    a.ranges or= @selectedRanges
    a.highlights or= []

    a.ranges = for r in a.ranges
      sniffed    = Range.sniff(r)
      normed     = sniffed.normalize(@wrapper)
      serialized = normed.serialize(@wrapper, '.annotator-hl')

    a.quote = normed.text()
    a.highlights = this.highlightRange(normed)

    # Save the annotation data on each highlighter element.
    $(a.highlights).data('annotation', a)

    # Fire annotationCreated events so that plugins can react to them.
    if fireEvents
      $(@element).trigger('annotationCreated', [a])

    a

  deleteAnnotation: (annotation) ->
    for h in annotation.highlights
      $(h).replaceWith(h.childNodes)

    $(@element).trigger('annotationDeleted', [annotation])

  updateAnnotation: (annotation) ->
    $(@element).trigger('beforeAnnotationUpdated', [annotation])
    $(@element).trigger('annotationUpdated', [annotation])

  loadAnnotations: (annotations=[]) ->
    results = []

    loader = (annList) =>
      now = annList.splice(0,10)

      for n in now
        results.push(this.createAnnotation(n, false)) # 'false' suppresses event firing

      # If there are more to do, do them after a 100ms break (for browser
      # responsiveness).
      if annList.length > 0
        setTimeout((-> loader(annList)), 100)

    loader(annotations) if annotations.length

  dumpAnnotations: () ->
    if @plugins['Store']
      @plugins['Store'].dumpAnnotations()
    else
      console.warn("Can't dump annotations without Store plugin.")

  highlightRange: (normedRange) ->
    elemList = for node in normedRange.textNodes()
      wrapper = @hl.clone().show()
      $(node).wrap(wrapper).parent().get(0)

  addPlugin: (name, options) ->
    if @plugins[name]
      console.error "You cannot have more than one instance of any plugin."
    else
      klass = Annotator.Plugin[name]
      if typeof klass is 'function'
        @plugins[name] = new klass(@element, options)
        @plugins[name].annotator = this
        @plugins[name].pluginInit?()
      else
        console.error "Could not load #{name} plugin. Have you included the appropriate <script> tag?"
    this # allow chaining

  showEditor: (annotation, location) =>
    $(@editor.element).css(location)
    @editor.load(annotation)

  onEditorHide: =>
    $(@element).trigger('annotationEditorHidden', [@editor])
    @ignoreMouseup = false

  onEditorSubmit: (event, annotation) =>
    $(@element).trigger('annotationEditorSubmit', [@editor, annotation])

    if annotation.ranges == undefined
      this.createAnnotation(annotation)
    else
      this.updateAnnotation(annotation)

  showViewer: (annotations, location) =>
    $(@viewer.element).css(location)
    @viewer.load(annotations)

    $(@element).trigger('annotationViewerShown', [@viewer, annotations])

  startViewerHideTimer: (e) =>
    # Don't do this if timer has already been set by another annotation.
    if not @viewerHideTimer
      # Allow 250ms for pointer to get from annotation to viewer to manipulate
      # annotations.
      @viewerHideTimer = setTimeout ((ann) -> ann.viewer.hide()), 250, this

  clearViewerHideTimer: () =>
    clearTimeout(@viewerHideTimer)
    @viewerHideTimer = false

  checkForStartSelection: (event) =>
    this.startViewerHideTimer()
    @mouseIsDown = true

  checkForEndSelection: (event) =>
    @mouseIsDown = false

    # This prevents the note image from jumping away on the mouseup
    # of a click on icon.
    if (@ignoreMouseup)
      return

    this.getSelection()

    s = @selection
    validSelection = s?.rangeCount > 0 and not s.isCollapsed

    if event and validSelection
      @adder
        .css(util.mousePosition(event, @wrapper))
        .show()
    else
      @adder.hide()

  onHighlightMouseover: (event) =>
    # Cancel any pending hiding of the viewer.
    this.clearViewerHideTimer()

    # Don't do anything if we're making a selection or
    # already displaying the viewer
    return false if @mouseIsDown or @viewer.isShown()

    annotations = $(event.target)
      .parents('.annotator-hl')
      .andSelf()
      .map -> return $(this).data("annotation")

    this.showViewer($.makeArray(annotations), util.mousePosition(event, @wrapper))

  onAdderMousedown: (event) =>
    event?.preventDefault()
    @ignoreMouseup = true

  onAdderClick: (event) =>
    event?.preventDefault()

    position = @adder.position()
    @adder.hide()

    # Create an annotation and display the editor.
    this.showEditor(this.createNewAnnotation(), position)

  onEditAnnotation: (event, annotation) =>
    offset = $(@viewer.element).position()

    # Replace the viewer with the editor.
    @viewer.hide()
    this.showEditor(annotation, offset)

  onDeleteAnnotation: (event, annotation) =>
    # Delete highlight elements.
    this.deleteAnnotation annotation

# Create namespace for Annotator plugins
class Annotator.Plugin extends Delegator
  constructor: (element, options) ->
    super

  pluginInit: ->

# Bind our local copy of jQuery so plugins can use the extensions.
Annotator.$ = $

# Returns true if the Annotator can be used in the current browser.
Annotator.supported = -> (-> !!this.getSelection)()

# Create global access for Annotator
$.plugin 'annotator', Annotator

# Export Annotator object.
this.Annotator = Annotator;
