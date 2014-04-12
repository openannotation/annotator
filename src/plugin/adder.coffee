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
    @mouseIsDown = false
    @ignoreMouseup = false
    @selectedRanges = null

  configure: ({@core}) ->

  pluginInit: ->
    this._addEvents()
    # Create adder. FIXME: Don't use @core.wrapper here.
    this.adder = $(adderHtml).appendTo(@core.wrapper).hide()

  destroy: ->
    this._removeEvents()

  _addEvents: ->
    $(@element)
    .on("click.#{ns}", '.annotator-adder button', this._onClick)
    .on("mousedown.#{ns}", '.annotator-adder button', this._onMousedown)

    if @element.ownerDocument?
      $(@element.ownerDocument)
      .on("mouseup.#{ns}", this._checkForEndSelection)
      .on("mousedown.#{ns}", this._checkForStartSelection)
    else
      console.warn("You created an instance of the Adder on an element that
                    doesn't have an ownerDocument. This probably won't work!
                    Please ensure the element is added to the DOM before the
                    plugin is configured:", @element)

  _removeEvents: ->
    $(@element).off(".#{ns}")

  # Event callback: called when the mouse button is depressed (and thus a DOM
  # selection might have been started).
  #
  # event - A mousedown Event object.
  #
  # Returns nothing.
  _checkForStartSelection: (event) =>
    @mouseIsDown = true

  # Event callback: called when the mouse button is released. Checks to see if a
  # selection has been made and if so displays the adder.
  #
  # event - A mouseup Event object.
  #
  # Returns nothing.
  _checkForEndSelection: (event) =>
    @mouseIsDown = false

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
      # FIXME: Don't use @core.wrapper here.
      @adder
        .css(Util.mousePosition(event, @core.wrapper[0]))
        .show()
    else
      @adder.hide()

  # Public: Gets the current selection excluding any nodes that fall outside of
  # the wrapper element. Then returns an Array of NormalizedRange instances.
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
        # FIXME: Don't use @core.wrapper here.
        normedRange = browserRange.normalize().limit(@core.wrapper[0])

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

    # Remove any ranges that fell outside of @core.wrapper.
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
    event?.preventDefault()

    # Hide the adder
    position = @adder.position()
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
      # FIXME: don't use @core.wrapper here
      annotation.ranges.push(
        normed.serialize(@core.wrapper[0], '.annotator-hl')
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
      .not(@core.wrapper) # FIXME: don't use @core.wrapper here
      .length


# This is a core plugin (registered by default with Annotator), so we don't
# register here. If you're writing a plugin of your own, please refer to a
# non-core plugin (such as Document or Store) to see how to register your plugin
# with Annotator.

module.exports = Adder
