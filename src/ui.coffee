Range = require('xpath-range').Range

Util = require('./util')
Widget = require('./widget')

$ = Util.$
_t = Util.TranslationString

ADDER_NS = 'annotator-adder'
TEXTSELECTOR_NS = 'annotator-textselector'

ADDER_HTML =
  """
  <div class="annotator-adder annotator-hide">
    <button type="button">#{_t('Annotate')}</button>
  </div>
  """


# Adder shows and hides an annotation adder button that can be clicked on to
# create an annotation.
class Adder extends Widget
  events:
    "button click": "_onClick"
    "button mousedown": "_onMousedown"

  template: ADDER_HTML

  constructor: (registry, options) ->
    super options
    @registry = registry
    @ignoreMouseup = false

    @interactionPoint = null
    @selectedRanges = null

    @document = @element[0].ownerDocument
    $(@document.body).on("mouseup.#{ADDER_NS}", this._onMouseup)
    this.render()

  destroy: ->
    super
    $(@document.body).off(".#{ADDER_NS}")

  onSelection: (ranges, event) =>
    if ranges?.length > 0
      @selectedRanges = ranges
      @interactionPoint = Util.mousePosition(event)
      this.show()
    else
      @selectedRanges = []
      @interactionPoint = null
      this.hide()

  # Public: Show the adder.
  #
  # Returns nothing.
  show: =>
    if @interactionPoint?
      @element.css({
        top: @interactionPoint.top,
        left: @interactionPoint.left
      })
    super

  # Event callback: called when the mouse button is depressed on the adder.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  _onMousedown: (event) ->
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    event?.preventDefault()
    # Prevent the selection code from firing when the mouse button is released
    @ignoreMouseup = true

  # Event callback: called when the mouse button is released
  #
  # event - A mouseup Event object
  #
  # Returns nothing.
  _onMouseup: (event) ->
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    # Prevent the selection code from firing when the ignoreMouseup flag is set
    if @ignoreMouseup
      event.stopImmediatePropagation()


  # Event callback: called when the adder is clicked. The click event is used as
  # well as the mousedown so that we get the :active state on the adder when
  # clicked.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  _onClick: (event) ->
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    event?.preventDefault()

    # Hide the adder
    this.hide()
    @ignoreMouseup = false

    # Create a new annotation
    @registry.annotations.create({
      ranges: @selectedRanges
    })


# TextSelector monitors a document (or a specific element) for text selections
# and can notify another object of a selection event
class TextSelector

  constructor: (element, options) ->
    @element = element
    @options = options

    if @element.ownerDocument?
      @document = @element.ownerDocument
      $(@document.body)
      .on("mouseup.#{TEXTSELECTOR_NS}", this._checkForEndSelection)
    else
      console.warn("You created an instance of the TextSelector on an element
                    that doesn't have an ownerDocument. This won't work! Please
                    ensure the element is added to the DOM before the plugin is
                    configured:", @element)

  destroy: ->
    $(@document.body).off(".#{TEXTSELECTOR_NS}")

  # Public: capture the current selection from the document, excluding any nodes
  # that fall outside of the adder's `element`.
  #
  # Returns an Array of NormalizedRange instances.
  captureDocumentSelection: ->
    selection = Util.getGlobal().getSelection()

    ranges = []
    rangesToIgnore = []
    unless selection.isCollapsed
      ranges = for i in [0...selection.rangeCount]
        r = selection.getRangeAt(i)
        browserRange = new Range.BrowserRange(r)
        normedRange = browserRange.normalize().limit(@element)

        # If the new range falls fully outside our @element, we should add it
        # back to the document but not return it from this method.
        rangesToIgnore.push(r) if normedRange is null

        normedRange

      # BrowserRange#normalize() modifies the DOM structure and deselects the
      # underlying text as a result. So here we remove the selected ranges and
      # reapply the new ones.
      selection.removeAllRanges()

    for r in rangesToIgnore
      selection.addRange(r)

    # Remove any ranges that fell outside @element.
    ranges = $.grep(ranges, (range) ->
      # Add the normed range back to the selection if it exists.
      if range
        drange = @document.createRange()
        drange.setStartBefore(range.start)
        drange.setEndAfter(range.end)
        selection.addRange(drange)
      range
    )

    return ranges

  # Event callback: called when the mouse button is released. Checks to see if a
  # selection has been made and if so displays the adder.
  #
  # event - A mouseup Event object.
  #
  # Returns nothing.
  _checkForEndSelection: (event) =>
    _nullSelection = =>
      if typeof @options.onSelection == 'function'
        @options.onSelection([], event)

    # Get the currently selected ranges.
    selectedRanges = this.captureDocumentSelection()

    if selectedRanges.length == 0
      _nullSelection()
      return

    # Don't show the adder if the selection was of a part of Annotator itself.
    for range in selectedRanges
      container = range.commonAncestor
      if $(container).hasClass('annotator-hl')
        container = $(container).parents('[class!=annotator-hl]')[0]
      if this._isAnnotator(container)
        _nullSelection()
        return

    if typeof @options.onSelection == 'function'
      @options.onSelection(selectedRanges, event)


  # Determines if the provided element is part of Annotator. Useful for ignoring
  # mouse actions on the annotator elements.
  #
  # element - An Element or TextNode to check.
  #
  # Returns true if the element is a child of an annotator element.
  _isAnnotator: (element) ->
    !!$(element)
      .parents()
      .addBack()
      .filter('[class^=annotator-]')
      .length


exports.Adder = Adder
exports.TextSelector = TextSelector
