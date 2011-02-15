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
    ".annotator-adder mousedown":          "adderMousedown"
    ".annotator-hl mouseover":             "highlightMouseover"
    ".annotator-hl mouseout":              "startViewerHideTimer"
    ".annotator-viewer mouseover":         "clearViewerHideTimer"
    ".annotator-viewer mouseout":          "startViewerHideTimer"
    ".annotator-editor textarea keydown":  "processEditorKeypress"
    ".annotator-editor form submit":       "submitEditor"
    ".annotator-editor button.annotator-editor-save click": "submitEditor"
    ".annotator-editor button.annotator-editor-cancel click": "hideEditor"
    ".annotator-ann-controls .edit click": "controlEditClick"
    ".annotator-ann-controls .del click":  "controlDeleteClick"

    # TODO: allow for adding these events on document.body
    "mouseup":   "checkForEndSelection"
    "mousedown": "checkForStartSelection"

  dom:
    adder:  "<div class='annotator-adder'><a href='#'></a></div>"
    editor: """
            <div class='annotator-editor'>
              <form>
                <textarea rows='6' cols='30'></textarea>
                <div class='annotator-editor-controls'>
                  <button type='submit' class='annotator-editor-save'>Save</button>
                  <button type='submit' class='annotator-editor-cancel'>Cancel</button>
                </div>
              <form>
            </div>
            """
    hl:     "<span class='annotator-hl'></span>"
    viewer: "<div class='annotator-viewer'></div>"

  options: {} # Configuration options

  constructor: (element, options) ->
    super

    # Plugin registry
    @plugins = {}

    # Wrap element contents
    @wrapper = $("<div></div>").addClass('annotator-wrapper')
    $(@element).wrapInner(@wrapper)
    @wrapper = $(@element).contents().get(0)

    # Create model dom elements
    for name, src of @dom
      @dom[name] = $(src)
        .hide()
        .appendTo(@wrapper)

    # Bind delegated events.
    this.addEvents()

  checkForStartSelection: (e) =>
    this.startViewerHideTimer()
    @mouseIsDown = true

  checkForEndSelection: (e) =>
    @mouseIsDown = false

    # This prevents the note image from jumping away on the mouseup
    # of a click on icon.
    if (@ignoreMouseup)
      return

    this.getSelection()

    s = @selection
    validSelection = s?.rangeCount > 0 and not s.isCollapsed

    if e and validSelection
      @dom.adder
        .css(util.mousePosition(e, @wrapper))
        .show()
    else
      @dom.adder.hide()

  getSelection: ->
    # TODO: fail gracefully in IE.
    @selection = util.getGlobal().getSelection()
    @selectedRanges = (@selection.getRangeAt(i) for i in [0...@selection.rangeCount])

  createAnnotation: (annotation, fireEvents=true) ->
    a = annotation

    a or= {}
    a.ranges or= @selectedRanges
    a.highlights or= []

    a.ranges = for r in a.ranges
      sniffed    = Range.sniff(r)
      normed     = sniffed.normalize(@wrapper)
      serialized = normed.serialize(@wrapper, '.annotator-hl')

    a.highlights = this.highlightRange(normed)

    # Save the annotation data on each highlighter element.
    $(a.highlights).data('annotation', a)

    # Fire annotationCreated events so that plugins can react to them.
    if fireEvents
      $(@element).trigger('beforeAnnotationCreated', [a])
      $(@element).trigger('annotationCreated', [a])

    a

  deleteAnnotation: (annotation) ->
    for h in annotation.highlights
      $(h).replaceWith($(h)[0].childNodes)

    $(@element).trigger('annotationDeleted', [annotation])

  updateAnnotation: (annotation, data) ->
    $.extend(annotation, data)
    $(@element).trigger('beforeAnnotationUpdated', [annotation])
    $(@element).trigger('annotationUpdated', [annotation])

  loadAnnotations: (annotations) ->
    results = []

    loader = (annList) =>
      now = annList.splice(0,10)

      for n in now
        results.push(this.createAnnotation(n, false)) # 'false' suppresses event firing

      # If there are more to do, do them after a 100ms break (for browser
      # responsiveness).
      if annList.length > 0
        setTimeout((-> loader(annList)), 100)

    loader(annotations)

  dumpAnnotations: () ->
    if @plugins['Store']
      @plugins['Store'].dumpAnnotations()
    else
      console.warn("Can't dump annotations without Store plugin.")

  highlightRange: (normedRange) ->
    textNodes = $(normedRange.commonAncestor).textNodes()
    [start, end] = [textNodes.index(normedRange.start), textNodes.index(normedRange.end)]
    textNodes = textNodes[start..end]

    elemList = for node in textNodes
      wrapper = @dom.hl.clone().show()
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

  showEditor: (e, annotation) =>
    if annotation
      @dom.editor.data('annotation', annotation)
      @dom.editor.find('textarea').val(annotation.text)

    @dom.editor
      .css(util.mousePosition(e, @wrapper))
      .show()
    .find('textarea')
      .focus()

    $(@element).trigger('annotationEditorShown', [@dom.editor, annotation])


  hideEditor: (e) =>
    e?.preventDefault()

    @dom.editor
      .data('annotation', null)
      .hide()
    .find('textarea')
      .val('')

    $(@element).trigger('annotationEditorHidden', [@dom.editor])
    @ignoreMouseup = false

  processEditorKeypress: (e) =>
    if e.keyCode is 27 # "Escape" key => abort.
      this.hideEditor(e)
    else if e.keyCode is 13 && !e.shiftKey
      # If "return" was pressed without the shift key, we're done.
      this.submitEditor(e)

  submitEditor: (e) =>
    e?.preventDefault()

    textarea = @dom.editor.find('textarea')
    annotation = @dom.editor.data('annotation')

    if not annotation
      create = true
      annotation = {}

    $(@element).trigger('annotationEditorSubmit', [@dom.editor, annotation])

    if create
      annotation.text = textarea.val()
      this.createAnnotation(annotation)
    else
      this.updateAnnotation(annotation, { text: textarea.val() })

    this.hideEditor()

  showViewer: (e, annotations) =>
    controlsHTML = """
                   <span class="annotator-ann-controls">
                     <a href="#" class="edit" alt="Edit" title="Edit this annotation">Edit</a>
                     <a href="#" class="del" alt="X" title="Delete this annotation">Delete</a>
                   </span>
                   """

    viewerclone = @dom.viewer.clone().empty()

    for annot in annotations
      # As well as filling the viewer element, we also copy the annotation
      # object from the highlight element to the <div> containing the note
      # and controls. This makes editing/deletion much easier.
      $("""
        <div class='annotator-ann'>
          #{controlsHTML}
          <div class='annotator-ann-text'>
            <p>#{annot.text}</p>
          </div>
        </div>
        """)
        .appendTo(viewerclone)
        .data("annotation", annot)

    viewerclone
      .css(util.mousePosition(e, @wrapper))
      .replaceAll(@dom.viewer).show()

    $(@element).trigger('annotationViewerShown', [viewerclone.get(0), annotations])

    @dom.viewer = viewerclone

  startViewerHideTimer: (e) =>
    # Don't do this if timer has already been set by another annotation.
    if not @viewerHideTimer
      # Allow 250ms for pointer to get from annotation to viewer to manipulate
      # annotations.
      @viewerHideTimer = setTimeout ((ann) -> ann.dom.viewer.hide()), 250, this

  clearViewerHideTimer: () =>
    clearTimeout(@viewerHideTimer)
    @viewerHideTimer = false

  highlightMouseover: (e) =>
    # Cancel any pending hiding of the viewer.
    this.clearViewerHideTimer()

    # Don't do anything if we're making a selection.
    return false if @mouseIsDown

    annotations = $(e.target)
      .parents('.annotator-hl')
      .andSelf()
      .map -> $(this).data("annotation")

    this.showViewer(e, annotations)

  adderMousedown: (e) =>
    e?.preventDefault()
    @ignoreMouseup = true
    @dom.adder.hide()
    this.showEditor(e)

  controlEditClick: (e) =>
    annot = $(e.target).parents('.annotator-ann')
    offset = $(@dom.viewer).offset()
    pos =
      pageY: offset.top,
      pageX: offset.left

    # Replace the viewer with the editor.
    @dom.viewer.hide()
    this.showEditor pos, annot.data("annotation")
    false

  controlDeleteClick: (e) =>
    annot = $(e.target).parents('.annotator-ann')

    # Delete highlight elements.
    this.deleteAnnotation annot.data("annotation")

    # Remove from viewer and hide viewer if this was the only annotation displayed.
    annot.remove()
    @dom.viewer.hide() unless @dom.viewer.is(':parent')

    false

# Create namespace for Annotator plugins
class Annotator.Plugin extends Delegator
  constructor: (element, options) ->
    super

  pluginInit: ->

# Create global access for Annotator
$.plugin('annotator', Annotator)
