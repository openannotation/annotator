Range = require('../range')
Util = require('../util')
$ = Util.$
_t = Util.TranslationString

SELECT_NS = 'annotator-textselect'

# Public: Provide support to annotate text selections in HTML documents
class TextSelector

  constructor: (element) ->
    @element = element

  configure: ({@core}) ->

  pluginInit: ->
    if @element.ownerDocument?
      @document = @element.ownerDocument
      $(@document.body)
      .on("mouseup.#{SELECT_NS}", this._checkForEndSelection)
    else
      console.warn("You created an instance of the TextSelector on an element that
                    doesn't have an ownerDocument. This won't work! Please
                    ensure the element is added to the DOM before the plugin is
                    configured:", @element)

  destroy: ->
    $(@document.body).off(".#{SELECT_NS}")

  # Public: Create a skeleton for an annotation, based on a list of ranges.
  #
  # ranges - An Array of NormalizedRanges to use when creating the annotation.
  #
  # Returns the data structure which should be used to init the annotation.
  createSkeleton: (ranges) ->
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
    if @core.ignoreMouseup
      return

    # Get the currently selected ranges.
    selectedRanges = this.captureDocumentSelection()

    if selectedRanges.length == 0
      @core.onFailedSelection?()
      return

    # Don't show the adder if the selection was of a part of Annotator itself.
    for range in selectedRanges
      container = range.commonAncestor
      if $(container).hasClass('annotator-hl')
        container = $(container).parents('[class!=annotator-hl]')[0]
      if this._isAnnotator(container)
        @core.onFailedSelection?()
        return

    # If we got this far, there are real selected ranges on a part of the page
    # we're interested in. Show the adder!
    @core.interactionPoint = Util.mousePosition(event)
    @core.selectedSkeleton = this.createSkeleton(selectedRanges)

    @core.onSuccessfulSelection?()


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

module.exports = TextSelector
