class Annotator.Plugin.Selector extends Annotator.Plugin
  # Events to be bound to the Annotator#element.
  events:
    ".annotator-wrapper mousedown":    "checkForSelectionStart"
    ".annotator-wrapper mouseup":      "checkForSelectionEnd"

  checkForSelectionStart: (event) =>
    @annotator.publish('selectionStart')

  # Annotator#element callback. Checks to see if a selection has been made
  # on mouseup and if so displays the Annotator#adder. If @ignoreMouseup is
  # set will do nothing.
  #
  # event - A mouseup Event object.
  #
  # Returns nothing.
  checkForSelectionEnd: (event) =>
    # Get the currently selected ranges.
    selectedRanges = this.getSelectedRanges()

    for range in selectedRanges
      container = range.commonAncestor
      return if @annotator.isAnnotator(container)

    @annotator.publish('selectionEnd', selectedRanges)

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
    selection = util.getGlobal().getSelection()

    ranges = []
    rangesToIgnore = []
    unless selection.isCollapsed
      ranges = for i in [0...selection.rangeCount]
        r = selection.getRangeAt(i)
        browserRange = new Range.BrowserRange(r)
        normedRange = browserRange.normalize().limit(@annotator.wrapper[0])

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
