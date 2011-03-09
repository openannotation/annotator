Range = {}

# Public: Determines the type of Range of the provided object and returns
# a suitable Range instance.
#
# r - A range Object.
#
# Examples
#
#   selection = window.getSelection()
#   Range.sniff(selection.getRangeAt(0))
#   # => Returns a BrowserRange instance.
#
# Returns 
Range.sniff = (r) ->
  if r.commonAncestorContainer?
    new Range.BrowserRange(r)
  else if typeof r.start is "string"
    new Range.SerializedRange(r)
  else if r.start and typeof r.start is "object"
    new Range.NormalizedRange(r)
  else
    console.error("Couldn't not sniff range type")
    false

# Public: Creates a wrapper around a range object obtained from a DOMSelection.
class Range.BrowserRange

  # Public: Creates an instance of BrowserRange.
  #
  # object - A range object obtained via DOMSelection#getRangeAt().
  #
  # Examples
  #
  #   selection = window.getSelection()
  #   range = new Range.BrowserRange(selection.getRangeAt(0))
  #
  # Returns an instance of BrowserRange.
  constructor: (obj) ->
    @commonAncestorContainer = obj.commonAncestorContainer
    @startContainer          = obj.startContainer
    @startOffset             = obj.startOffset
    @endContainer            = obj.endContainer
    @endOffset               = obj.endOffset

  # Public: normalize works around the fact that browsers don't generate
  # ranges/selections in a consistent manner. Some (Safari) will create
  # ranges that have (say) a textNode startContainer and elementNode
  # endContainer. Others (Firefox) seem to only ever generate
  # textNode/textNode or elementNode/elementNode pairs.
  #
  # Returns an instance of Range.NormalizedRange
  normalize: (root) ->
    if @tainted
      console.error("You may only call normalize() once on a BrowserRange!")
      return false
    else
      @tainted = true

    r = {}
    nr = {}

    for p in ['start', 'end']
      node = this[p + 'Container']
      offset = this[p + 'Offset']

      # elementNode nodeType == 1
      if node.nodeType is 1
        # Get specified node.
        it = node.childNodes[offset]
        # If it doesn't exist, that means we need the end of the
        # previous one.
        node = it or node.childNodes[offset - 1]

        # textNode nodeType == 3
        while node.nodeType isnt 3
          node = node.firstChild

        offset = if it then 0 else node.nodeValue.length

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
    nr.commonAncestor = @commonAncestorContainer
    # elementNode nodeType == 1
    while nr.commonAncestor.nodeType isnt 1
      nr.commonAncestor = nr.commonAncestor.parentNode

    new Range.NormalizedRange(nr)

  # Public: Creates a range suitable for storage.
  #
  # root           - A root Element from which to anchor the serialisation.
  # ignoreSelector - A selector String of elements to ignore. For example
  #                  elements injected by the annotator.
  #
  # Returns an instance of SerializedRange.
  serialize: (root, ignoreSelector) ->
    this.normalize(root).serialize(root, ignoreSelector)

# Public: A normalised range is most commonly used throughout the annotator.
# its the result of a deserialised SerializedRange or a BrowserRange with
# out browser inconsistencies.
class Range.NormalizedRange

  # Public: Creates an instance of a NormalizedRange.
  #
  # This is usually created by calling the .normalize() method on one of the
  # other Range classes rather than manually.
  #
  # obj - An Object literal. Should have the following properties.
  #       commonAncestor: A Element that encompasses both the start and end nodes
  #       start:          The first TextNode in the range.
  #       end             The last TextNode in the range.
  #
  # Returns an instance of NormalizedRange.
  constructor: (obj) ->
    @commonAncestor = obj.commonAncestor
    @start          = obj.start
    @end            = obj.end

  # Public: For API consistency.
  #
  # Returns itself.
  normalize: (root) ->
    this

  # Public: Limits the nodes within the NormalizedRange to those contained
  # withing the bounds parameter. It returns an updated range with all
  # properties updated. NOTE: Method returns null if all nodes fall outside
  # of the bounds.
  #
  # bounds - An Element to limit the range to.
  #
  # Returns updated self or null.
  limit: (bounds) ->
    nodes = $.grep this.textNodes(), (node) ->
      node.parentNode == bounds or $.contains(bounds, node.parentNode)

    return null unless nodes.length

    @start = nodes[0]
    @end   = nodes[nodes.length - 1]

    startParents = $(@start).parents()
    for parent in $(@end).parents()
      if startParents.index(parent) != -1
        @commonAncestor = parent
        break
    this

  # Convert this range into an object consisting of two pairs of (xpath,
  # character offset), which can be easily stored in a database.
  #
  # root -           The root Element relative to which XPaths should be calculated
  # ignoreSelector - A selector String of elements to ignore. For example
  #                  elements injected by the annotator.
  #
  # Returns an instance of SerializedRange.
  serialize: (root, ignoreSelector) ->

    serialization = (node, isEnd) ->
      if ignoreSelector
        origParent = $(node).parents(":not(#{ignoreSelector})").eq(0)
      else
        origParent = $(node).parent()

      xpath = origParent.xpath(root)[0]
      textNodes = origParent.textNodes()

      # Calculate real offset as the combined length of all the
      # preceding textNode siblings. We include the length of the
      # node if it's the end node.
      nodes = textNodes.slice(0, textNodes.index(node))
      offset = 0
      for n in nodes
        offset += n.nodeValue.length

      if isEnd then [xpath, offset + node.nodeValue.length] else [xpath, offset]

    start = serialization(@start)
    end   = serialization(@end, true)

    new Range.SerializedRange({
      # XPath strings
      start: start[0]
      end: end[0]
      # Character offsets (integer)
      startOffset: start[1]
      endOffset: end[1]
    })

  # Public: Creates a concatenated String of the contents of all the text nodes
  # within the range.
  #
  # Returns a String.
  text: ->
    (for node in this.textNodes()
      node.nodeValue
    ).join ''

  # Public: Fetches only the text nodes within th range.
  #
  # Returns an Array of TextNode instances.
  textNodes: ->
    textNodes = $(this.commonAncestor).textNodes()
    [start, end] = [textNodes.index(this.start), textNodes.index(this.end)]
    # Return the textNodes that fall between the start and end indexes.
    $.makeArray textNodes[start..end]

# Public: A range suitable for storing in local storage or serializing to JSON.
class Range.SerializedRange

  # Public: Creates a SerializedRange
  #
  # obj - The stored object. It should have the following properties.
  #       start:       An xpath to the Element containing the first TextNode
  #                    relative to the root Element.
  #       startOffset: The offset to the start of the selection from obj.start.
  #       end:         An xpath to the Element containing the last TextNode
  #                    relative to the root Element.
  #       startOffset: The offset to the end of the selection from obj.end. 
  #
  # Returns an instance of SerializedRange
  constructor: (obj) ->
    @start       = obj.start
    @startOffset = obj.startOffset
    @end         = obj.end
    @endOffset   = obj.endOffset

  # Public: Creates a NormalizedRange.
  #
  # root - The root Element from which the XPaths were generated.
  #
  # Returns a NormalizedRange instance.
  normalize: (root) ->
    nodeFromXPath = (xpath) ->
      document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue

    parentXPath   = $(root).xpath()[0]
    startAncestry = @start.split("/")
    endAncestry   = @end.split("/")
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
      return null

    # Unfortunately, we *can't* guarantee only one textNode per
    # elementNode, so we have to walk along the element's textNodes until
    # the combined length of the textNodes to that point exceeds or
    # matches the value of the offset.
    for p in ['start', 'end']
      length = 0
      for tn in $(nodeFromXPath(parentXPath + this[p])).textNodes()
        if (length + tn.nodeValue.length >= this[p + 'Offset'])
          range[p + 'Container'] = tn
          range[p + 'Offset'] = this[p + 'Offset'] - length
          break
        else
          length += tn.nodeValue.length

    new Range.BrowserRange(range).normalize(root)

  # Public: Creates a range suitable for storage.
  #
  # root           - A root Element from which to anchor the serialisation.
  # ignoreSelector - A selector String of elements to ignore. For example
  #                  elements injected by the annotator.
  #
  # Returns an instance of SerializedRange.
  serialize: (root, ignoreSelector) ->
    this.normalize(root).serialize(root, ignoreSelector)

  # Public: Returns the range as an Object literal.
  toObject: ->
    {
      start: @start
      startOffset: @startOffset
      end: @end
      endOffset: @endOffset
    }
