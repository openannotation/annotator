# Selection and range creation reference for the following code:
# http://www.quirksmode.org/dom/range_intro.html
#
# I've removed any support for IE TextRange (see commit d7085bf2 for code)
# for the moment, having no means of testing it.

$ = jQuery
window = this

util =
  mousePosition: (e, offsetEl) ->
    offset = $(offsetEl).offset()
    {
      top:  e.pageY - offset.top,
      left: e.pageX - offset.left
    }

class Annotator extends Delegator
  events:
    "-adder mousedown":       "adderMousedown"
    "-highlighter mouseover": "highlightMouseover"
    "-highlighter mouseout":  "startViewerHideTimer"
    "-viewer mouseover":      "viewerMouseover"
    "-viewer mouseout":       "startViewerHideTimer"
    "-controls .edit click":  "controlEditClick"
    "-controls .del click":   "controlDeleteClick"
    # TODO: allow for adding these events on document.body
    "mouseup":                "checkForEndSelection"
    "mousedown":              "checkForStartSelection"

  options:
    classPrefix: "annot" # Class used to identify elements owned/created by the annotator.

    dom:
      adder:       "<div><a href='#'></a></div>"
      editor:      "<div><textarea></textarea></div>"
      highlighter: "<span></span>"
      viewer:      "<div></div>"

  constructor: (element, options) ->
    super

    # Wrap element contents
    @wrapper = $("<div></div>").addClass(this.componentClassname('wrapper'))
    $(@element).wrapInner(@wrapper)
    @wrapper = $(@element).contents().get(0)

    # For all events beginning with '-', map them to a meaningful selector.
    # e.g. '-adder click' -> '.annot-adder click'
    for k, v of @events
      if k[0] is '-'
        @events['.' + @options.classPrefix + k] = v
        delete @events[k]

    # Create model dom elements
    @dom = {}
    for name, src of @options.dom
      @dom[name] = $(src)
        .addClass(this.componentClassname(name))
        .appendTo(@wrapper)
        .hide()

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
      @ignoreMouseup = false
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
    @selection = window.getSelection()
    @selectedRanges = (@selection.getRangeAt(i) for i in [0...@selection.rangeCount])

  createAnnotation: (annotation) ->
    a = annotation

    a or= {}
    a.ranges or= @selectedRanges
    a.highlights or= []

    a.ranges = for r in a.ranges
      if r.commonAncestorContainer?
        # range from a browser
        normed = this.normRange(r)
        serialized = this.serializeRange(normed)
      else if r.start and typeof r.start is "string"
        # serialized range
        normed = this.deserializeRange(r)
        serialized = r
      else
        # presume normed
        normed = r
        serialized = this.serializeRange(normed)

      serialized

    a.highlights = this.highlightRange(normed)

    # Save the annotation data on each highlighter element.
    $(a.highlights).data('annotation', a)
    # Fire annotationCreated event so that others can react to it.
    $(@element).trigger('annotationCreated', [a])

    a

  deleteAnnotation: (annotation) ->
    for h in annotation.highlights
      $(h).replaceWith($(h)[0].childNodes)

    $(@element).trigger('annotationDeleted', [annotation])

  updateAnnotation: (annotation, data) ->
    $.extend(annotation, data)
    $(@element).trigger('annotationUpdated', [annotation])

  loadAnnotations: (annotations, callback) ->
    results = []

    loader = (annList) =>
      now = annList.splice(0,10)

      for n in now
        results.push(this.createAnnotation(n))

      # If there are more to do, do them after a 100ms break (for browser
      # responsiveness).
      if annList.length > 0
        setTimeout (-> loader(annList)), 100
      else
        callback(results) if callback

    loader(annotations)

  # normRange: works around the fact that browsers don't generate
  # ranges/selections in a consistent manner. Some (Safari) will create
  # ranges that have (say) a textNode startContainer and elementNode
  # endContainer. Others (Firefox) seem to only ever generate
  # textNode/textNode or elementNode/elementNode pairs.
  #
  # This will return a (start, end, commonAncestor) triple, where start and
  # end are textNodes, and commonAncestor is an elementNode.
  #
  # NB: This method may well split textnodes (i.e. alter the DOM) to
  # achieve this.
  normRange: (range) ->
    r = {}
    nr = {}

    for p in ['start', 'end']
      node = range[p + 'Container']
      offset = range[p + 'Offset']

      if node.nodeType is Node.ELEMENT_NODE
        # Get specified node.
        it = node.childNodes[offset]
        # If it doesn't exist, that means we need the end of the
        # previous one.
        node = it or node.childNodes[offset - 1]
        while node.nodeType isnt Node.TEXT_NODE
          node = node.firstChild
        offset = it ? 0 : node.nodeValue.length

      r[p] = node
      r[p + 'Offset'] = offset

    nr.start = if r.startOffset > 0 then r.start.splitText(r.startOffset) else r.start

    if r.start is r.end
      if (r.endOffset - r.startOffset) < nr.start.nodeValue.length
        nr.start.splitText(r.endOffset - r.startOffset)
      nr.end = nr.start
    else
      if r.endOffset < r.end.nodeValue.length
        r.end.splitText(r.endOffset)
      nr.end = r.end

    # Make sure the common ancestor is an element node.
    nr.commonAncestor = range.commonAncestorContainer
    while nr.commonAncestor.nodeType isnt Node.ELEMENT_NODE
      nr.commonAncestor = nr.commonAncestor.parentNode

    nr

  # serializeRange: takes a normedRange and turns it into a
  # serializedRange, which is two pairs of (xpath, character offset), which
  # can be easily stored in a database and loaded through
  # #loadAnnotations/#deserializeRange.
  serializeRange: (normedRange) ->

    serialization = (node, isEnd) =>
      origParent = $(node).parents(":not(.#{this.componentClassname('highlighter')})").eq(0)
      xpath = origParent.xpath(@wrapper)[0]
      textNodes = origParent.textNodes()

      # Calculate real offset as the combined length of all the
      # preceding textNode siblings. We include the length of the
      # node if it's the end node.
      nodes = textNodes.slice(0, textNodes.index(node))
      offset = _(nodes).reduce ((acc, tn) -> acc + tn.nodeValue.length), 0

      if isEnd then [xpath, offset + node.nodeValue.length] else [xpath, offset]

    start = serialization(normedRange.start)
    end   = serialization(normedRange.end, true)

    {
      # XPath strings
      start: start[0]
      end: end[0]
      # Character offsets (integer)
      startOffset: start[1]
      endOffset: end[1]
    }

  deserializeRange: (serializedRange) ->
    nodeFromXPath = (xpath) ->
      document.evaluate( xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue

    parentXPath   = $(@wrapper).xpath()[0]
    startAncestry = serializedRange.start.split("/")
    endAncestry   = serializedRange.end.split("/")
    common = []
    range = {}

    # Crudely find a near common ancestor by walking down the XPath from
    # the root until the segments no longer match.
    for i in [0...startAncestry.length]
      if startAncestry[i] is endAncestry[i]
        common.push(startAncestry[i])
      else
        break

    cacXPath = parentXPath + common.join("/")
    range.commonAncestorContainer = nodeFromXPath(cacXPath)

    if not range.commonAncestorContainer
      console.error("Error deserializing range: can't find XPath '" + cacXPath + "'. Is this the right document?")

    # Unfortunately, we *can't* guarantee only one textNode per
    # elementNode, so we have to walk along the element's textNodes until
    # the combined length of the textNodes to that point exceeds or
    # matches the value of the offset.
    for p in ['start', 'end']
      length = 0
      $(nodeFromXPath(parentXPath + serializedRange[p])).textNodes().each ->
        if (length + this.nodeValue.length >= serializedRange[p + 'Offset'])
          range[p + 'Container'] = this
          range[p + 'Offset'] = serializedRange[p + 'Offset'] - length
          false # end each loop.
        else
          length += this.nodeValue.length
          true

    this.normRange(range)

  highlightRange: (normedRange) ->
    textNodes = $(normedRange.commonAncestor).textNodes()
    [start, end] = [textNodes.index(normedRange.start), textNodes.index(normedRange.end)]
    textNodes = textNodes[start..end]

    elemList = for node in textNodes
      wrapper = @dom.highlighter.clone().show()
      $(node).wrap(wrapper).parent().get(0)

  addPlugin: (name, options) ->
    name = name[0].toUpperCase() + name[1..]
    klass = Annotator.Plugins[name]
    if typeof klass is 'function'
      new klass(@element, options)
    else
      console.error "Could not load #{name} plugin. Have you included the appropriate <script> tag?"

  componentClassname: (name) ->
    @options.classPrefix + '-' + name

  showEditor: (e, annotation) =>
    self = this

    if annotation
      @dom.editor.find('textarea').val(annotation.text)

    @dom.editor
      .css(util.mousePosition(e, @wrapper))
      .show()
    .find('textarea')
      .focus()
      .bind 'keydown', (e) ->
        if e.keyCode is 27 # "Escape" key => abort.
          $(this).val('').unbind().parent().hide()

        else if e.keyCode is 13 && !e.shiftKey
          # If "return" was pressed without the shift key, we're done.
          $(this).unbind().parent().hide()
          if annotation
            self.updateAnnotation(annotation, { text: $(this).val() })
          else
            self.createAnnotation({ text: $(this).val() })
          # Clear <textarea>
          $(this).val('')
      .bind 'blur', (e) ->
        $(this).val('').unbind().parent().hide()

    @ignoreMouseup = true

  showViewer: (e, annotations) =>
    controlsHTML = """
                   <span class="#{this.componentClassname('controls')}">
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
        <div>
          <div class='#{@options.classPrefix}-text'>
            <p>#{annot.text}</p>
          </div>#{controlsHTML}
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
      .parents('.' + this.componentClassname('highlighter'))
      .andSelf()
      .map -> $(this).data("annotation")

    this.showViewer(e, annotations)

  adderMousedown: (e) =>
    @dom.adder.hide()
    this.showEditor(e)
    false

  viewerMouseover: (e) =>
    # Cancel any pending hiding of the viewer.
    this.clearViewerHideTimer()

  controlEditClick: (e) =>
    para = $(e.target).parents('p')
    offset = $(@dom.viewer).offset()
    pos =
      pageY: offset.top,
      pageX: offset.left

    # Replace the viewer with the editor.
    @dom.viewer.hide()
    this.showEditor pos, para.data("annotation")
    false

  controlDeleteClick: (e) =>
    para = $(e.target).parents('p')

    # Delete highlight elements.
    this.deleteAnnotation para.data("annotation")

    # Remove from viewer and hide viewer if this was the only annotation displayed.
    para.remove()
    @dom.viewer.hide() unless @dom.viewer.is(':parent')

    false

# Create namespace for Annotator plugins
Annotator.Plugins = {}

# Create global access for Annotator
$.plugin('annotator', Annotator)
this.Annotator = Annotator
