Range = require('../range')
Util = require('../util')
$ = Util.$
_t = Util.TranslationString

ADDER_NS = 'annotator-adder'
ADDER_HIDE_CLASS = 'annotator-hide'
ADDER_HTML = """
             <div class="annotator-adder #{ADDER_HIDE_CLASS}">
               <button type="button">#{_t('Annotate')}</button>
             </div>
             """

# Public: Provide an easy selection adder for HTML documents
class Adder

  constructor: (element) ->
    @element = element
    @ignoreMouseup = false

  configure: ({@core}) ->

  pluginInit: ->
    if @element.ownerDocument?
      @document = @element.ownerDocument
      @adder = $(ADDER_HTML).appendTo(@document.body)[0]
      $(@adder)
      .on("click.#{ADDER_NS}", 'button', this._onClick)
      .on("mousedown.#{ADDER_NS}", 'button', this._onMousedown)

      $(@document.body)
      .on("mouseup.#{ADDER_NS}", this._checkForEndSelection)
    else
      console.warn("You created an instance of the Adder on an element that
                    doesn't have an ownerDocument. This won't work! Please
                    ensure the element is added to the DOM before the plugin is
                    configured:", @element)

  destroy: ->
    $(@adder)
    .off(".#{ADDER_NS}")
    .remove()
    $(@document.body).off(".#{ADDER_NS}")

  # Public: Show the adder.
  #
  # Returns nothing.
  show: =>
    if @core.interactionPoint?
      $(@adder).css({
        top: @core.interactionPoint.top,
        left: @core.interactionPoint.left
      })
    $(@adder).removeClass(ADDER_HIDE_CLASS)

  # Public: Hide the adder.
  #
  # Returns nothing.
  hide: =>
    $(@adder).addClass(ADDER_HIDE_CLASS)

  # Public: Returns true if the adder is currently displayed, false otherwise.
  #
  # Examples
  #
  #   adder.show()
  #   adder.isShown() # => true
  #
  #   adder.hide()
  #   adder.isShown() # => false
  #
  # Returns true if the adder is visible.
  isShown: ->
    not $(@adder).hasClass(ADDER_HIDE_CLASS)

  # Public: Create an annotation.
  #
  # ranges - An Array of NormalizedRanges to use when creating the annotation.
  #          Defaults to the currently selected ranges within the document.
  #
  # Returns the initialised annotation.
  create: (ranges = null) ->
    if ranges is null
      ranges = this.captureDocumentSelection()

    annotation = {
      quote: [],
      ranges: [],
    }

    for normed in ranges
      annotation.quote.push($.trim(normed.text()))
      annotation.ranges.push(
        normed.serialize(@element, '.annotator-hl')
      )

    # Join all the quotes into one string.
    annotation.quote = annotation.quote.join(' / ')

    @core.annotations.create(annotation)

    return annotation

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
      selection.addRange(range.toRange()) if range
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
    # This prevents the note image from jumping away on the mouseup
    # of a click on icon.
    if @ignoreMouseup
      return

    # Get the currently selected ranges.
    @selectedRanges = this.captureDocumentSelection()

    if @selectedRanges.length == 0
      this.hide()
      return

    # Don't show the adder if the selection was of a part of Annotator itself.
    for range in @selectedRanges
      container = range.commonAncestor
      if $(container).hasClass('annotator-hl')
        container = $(container).parents('[class!=annotator-hl]')[0]
      if this._isAnnotator(container)
        this.hide()
        return

    # If we got this far, there are real selected ranges on a part of the page
    # we're interested in. Show the adder!
    @core.interactionPoint = Util.mousePosition(event)
    this.show()

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
    this.hide()
    @ignoreMouseup = false

    # Create a new annotation
    this.create(@selectedRanges)

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
