Range = require('../range')
Util = require('../util')
$ = Util.$
_t = Util.TranslationString

ns = 'annotator-adder'
adderHtml = """
            <div class="annotator-adder">
              <button type="button">#{_t('Annotate')}</button>
            </div>
            """

# Public: Provide an easy selection adder for HTML documents
class Adder

  constructor: (element) ->
    @element = element
    @ignoreMouseup = false
    @selectedRanges = null

  configure: ({@core}) ->

  pluginInit: ->
    if @element.ownerDocument?
      @document = @element.ownerDocument
      this.adder = $(adderHtml).appendTo(@document.body).hide()
      this._addEvents()
    else
      console.warn("You created an instance of the Adder on an element that
                    doesn't have an ownerDocument. This won't work! Please
                    ensure the element is added to the DOM before the plugin is
                    configured:", @element)

  destroy: ->
    this._removeEvents()

  _addEvents: ->
    $(@adder)
    .on("click.#{ns}", 'button', this._onClick)
    .on("mousedown.#{ns}", 'button', this._onMousedown)

    $(@document.body)
    .on("mouseup.#{ns}", this._checkForEndSelection)

  _removeEvents: ->
    $(@adder).off(".#{ns}")
    $(@document.body).off(".#{ns}")

  # Event callback: called when the mouse button is released. Checks to see if a
  # selection has been made and if so displays the adder.
  #
  # event - A mouseup Event object.
  #
  # Returns nothing.
  _checkForEndSelection: (event) =>
    # This prevents the note image from jumping away on the mouseup
    # of a click on icon.
    if @ignoreMouseup
      return

    # Get the currently selected ranges.
    @selectedRanges = this._getSelectedRanges()

    for range in @selectedRanges
      container = range.commonAncestor
      if $(container).hasClass('annotator-hl')
        container = $(container).parents('[class!=annotator-hl]')[0]
      return if this._isAnnotator(container)

    if event and @selectedRanges.length
      offset = @adder.parent().offset()
      interactionPoint = {
        top: event.pageY - offset.top,
        left: event.pageX - offset.left,
      }
      @core.interactionPoint = interactionPoint
      @adder
        .css(interactionPoint)
        .show()
    else
      @adder.hide()

  # Public: Gets the current selection excluding any nodes that fall outside of
  # the adder `element`. Then returns an Array of NormalizedRange instances.
  #
  # Returns Array of NormalizedRange instances.
  _getSelectedRanges: ->
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
    $.grep ranges, (range) ->
      # Add the normed range back to the selection if it exists.
      selection.addRange(range.toRange()) if range
      range

  # Event callback: called when the mouse button is depressed on the adder.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  _onMousedown: (event) =>
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    event?.preventDefault()
    # Prevent the selection code from firing when the mouse button is released
    @ignoreMouseup = true

  # Event callback: called when the adder is clicked. The click event is used as
  # well as the mousedown so that we get the :active state on the @adder when
  # clicked.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  _onClick: (event) =>
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    event?.preventDefault()

    # Hide the adder
    @adder.hide()
    @ignoreMouseup = false

    # Create a new annotation
    annotation = this._createAnnotation()
    @core.annotations.create(annotation)

  # Initialise an annotation, generating a serializable representation of the
  # annotation from the current selection.
  #
  # Returns the initialised annotation.
  _createAnnotation: ->
    annotation = {
      quote: [],
      ranges: [],
    }

    for normed in @selectedRanges
      annotation.quote.push($.trim(normed.text()))
      annotation.ranges.push(
        normed.serialize(@element, '.annotator-hl')
      )

    # Join all the quotes into one string.
    annotation.quote = annotation.quote.join(' / ')

    annotation

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


# This is a core plugin (registered by default with Annotator), so we don't
# register here. If you're writing a plugin of your own, please refer to a
# non-core plugin (such as Document or Store) to see how to register your plugin
# with Annotator.

module.exports = Adder
