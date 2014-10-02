Range = require('xpath-range').Range

Util = require('../util')

$ = Util.$

TEXTSELECTOR_NS = 'annotator-textselector'


# TextSelector monitors a document (or a specific element) for text selections
# and can notify another object of a selection event
class TextSelector

  # Configuration options
  options:
    onSelection: null # Callback, called when the user makes a selection.
                      # Receives the list of selected ranges (may be empty) and
                      # the DOM Event that was detected as a selection.

  constructor: (element, options) ->
    @element = element
    @options = $.extend(true, {}, @options, options)

    if @options.onSelection?
      @onSelection = @options.onSelection

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
    win = rangy ? Util.getGlobal()
    selection = win.getSelection()

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
      if typeof @onSelection == 'function'
        @onSelection([], event)

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

    if typeof @onSelection == 'function'
      @onSelection(selectedRanges, event)


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

exports.TextSelector = TextSelector
