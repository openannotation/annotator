$ = jQuery

this.Range = {}

Range.sniff = (r) ->
  if r.commonAncestorContainer?
    new Range.BrowserRange(r)
  else if r.start and typeof r.start is "string"
    new Range.SerializedRange(r)
  else if r.start and typeof r.start is "object"
    new Range.NormalizedRange(r)
  else
    console.error("Couldn't not sniff range type")
    false

class Range.BrowserRange

  constructor: (obj) ->
    @commonAncestorContainer = obj.commonAncestorContainer
    @startContainer          = obj.startContainer
    @startOffset             = obj.startOffset
    @endContainer            = obj.endContainer
    @endOffset               = obj.endOffset

  ##
  # normalize works around the fact that browsers don't generate
  # ranges/selections in a consistent manner. Some (Safari) will create
  # ranges that have (say) a textNode startContainer and elementNode
  # endContainer. Others (Firefox) seem to only ever generate
  # textNode/textNode or elementNode/elementNode pairs.
  #
  # This will return an instance of Range.NormalizedRange
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

      if node.nodeType is Node.ELEMENT_NODE
        # Get specified node.
        it = node.childNodes[offset]
        # If it doesn't exist, that means we need the end of the
        # previous one.
        node = it or node.childNodes[offset - 1]

        while node.nodeType isnt Node.TEXT_NODE
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
    while nr.commonAncestor.nodeType isnt Node.ELEMENT_NODE
      nr.commonAncestor = nr.commonAncestor.parentNode

    new Range.NormalizedRange(nr)

  serialize: (root, ignoreSelector) ->
    this.normalize(root).serialize(root, ignoreSelector)

class Range.NormalizedRange

  constructor: (obj) ->
    @commonAncestor = obj.commonAncestor
    @start          = obj.start
    @end            = obj.end

  normalize: (root) ->
    this

  ##
  # Convert this range into an object consisting of
  # two pairs of (xpath, character offset), which
  # can be easily stored in a database.
  #
  # @param {Element} root The root element relative to which XPaths should be calculated
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
      offset = _(nodes).reduce ((acc, tn) -> acc + tn.nodeValue.length), 0

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

class Range.SerializedRange

  constructor: (obj) ->
    @start       = obj.start
    @startOffset = obj.startOffset
    @end         = obj.end
    @endOffset   = obj.endOffset

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

  serialize: (root, ignoreSelector) ->
    this.normalize(root).serialize(root, ignoreSelector)

  toObject: ->
    {
      start: @start
      startOffset: @startOffset
      end: @end
      endOffset: @endOffset
    }
