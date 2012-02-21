testData = [
  [ 0,           13,  0,           27,  "habitant morbi",                                    "Partial node contents." ]
  [ 0,           0,   0,           37,  "Pellentesque habitant morbi tristique",             "Full node contents, textNode refs." ]
  [ '/p/strong', 0,   '/p/strong', 1,   "Pellentesque habitant morbi tristique",             "Full node contents, elementNode refs." ]
  [ 0,           22,  1,           12,  "morbi tristique senectus et",                       "Spanning 2 nodes." ]
  [ '/p/strong', 0,   1,           12,  "Pellentesque habitant morbi tristique senectus et", "Spanning 2 nodes, elementNode start ref." ]
  [ 1,           165, '/p/em',     1,   "egestas semper. Aenean ultricies mi vitae est.",    "Spanning 2 nodes, elementNode end ref." ]
  [ 9,           7,   12,          11,  "Level 2\n\n\n  Lorem ipsum",                        "Spanning multiple nodes, textNode refs." ]
  [ '/p',        0,   '/p',        8,   "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. Donec non enim in turpis pulvinar facilisis. Ut felis.", "Spanning multiple nodes, elementNode refs." ]
  [ '/p[2]',     0,   '/p[2]',     1,   "Lorem sed do eiusmod tempor.",                      "Full node contents with empty node at end."]
]

describe 'Range', ->
  r = null
  mockSelection = null

  beforeEach ->
    addFixture('range')
    mockSelection = (ii) -> new MockSelection(fix(), testData[ii])

  afterEach ->
    delete a
    clearFixtures()

  describe "SerializedRange", ->
    beforeEach ->
      r = new Range.SerializedRange({
        start: "/p/strong"
        startOffset: 13
        end: "/p/strong"
        endOffset: 27
      })

    describe "normalize", ->
      it "should return a normalized range", ->
        norm = r.normalize(fix())
        expect(norm instanceof Range.NormalizedRange).toBeTruthy()
        expect(norm.text()).toEqual("habitant morbi")

      it "should return null if it cannot normalize the range", ->
        spyOn(console, 'error')
        normedRange = r.normalize($('<div/>')[0])
        expect(normedRange).toBe(null)
        expect(console.error).toHaveBeenCalled()

    it "serialize() returns a serialized range", ->
      seri = r.serialize(fix())
      expect(seri.start).toEqual("/p/strong")
      expect(seri.startOffset).toEqual(13)
      expect(seri.end).toEqual("/p/strong")
      expect(seri.endOffset).toEqual(27)
      expect(seri instanceof Range.SerializedRange).toBeTruthy()

    it "toObject() returns a simple object", ->
      obj = r.toObject()
      expect(obj.start).toEqual("/p/strong")
      expect(obj.startOffset).toEqual(13)
      expect(obj.end).toEqual("/p/strong")
      expect(obj.endOffset).toEqual(27)
      expect(JSON.stringify(obj)).toEqual('{"start":"/p/strong","startOffset":13,"end":"/p/strong","endOffset":27}')

    describe "_nodeFromXPath", ->
      xpath = if window.require then "/html/body/p/strong" else "/html/body/div/p/strong"
      it "should parse a standard xpath string", ->
        node = r._nodeFromXPath xpath
        expect(node).toBe($('strong')[0])

      it "should parse an standard xpath string for an xml document", ->
        Annotator.$.isXMLDoc = -> true
        node = r._nodeFromXPath xpath
        expect(node).toBe($('strong')[0])

  describe "BrowserRange", ->
    beforeEach ->
      sel = mockSelection(0)
      r = new Range.BrowserRange(sel.getRangeAt(0))

    it "normalize() returns a normalized range", ->
      norm = r.normalize()
      expect(norm.start).toBe(norm.end)
      expect(textInNormedRange(norm)).toEqual('habitant morbi')

    testBrowserRange = (i) ->
      ->
        sel   = mockSelection(i)
        range = new Range.BrowserRange(sel.getRangeAt(0))
        norm  = range.normalize(fix())

        expect(textInNormedRange(norm)).toEqual(sel.expectation)

    for i in [0...testData.length]
      it "should parse test range #{i} (#{testData[i][5]})", testBrowserRange(i)

  describe "NormalizedRange", ->
    sel = null

    beforeEach ->
      sel = mockSelection(7)
      browserRange = new Range.BrowserRange(sel.getRangeAt(0))
      r = browserRange.normalize()

    it "textNodes() returns an array of textNodes", ->
      textNodes = r.textNodes()

      expect($.type(textNodes)).toEqual('array')
      expect(textNodes.length).toEqual(sel.endOffset)

      # Should contain the contents of the first <strong> element.
      expect(textNodes[0].nodeValue).toEqual('Pellentesque habitant morbi tristique')

    it "text() returns the textual contents of the range", ->
      expect(r.text()).toEqual(sel.expectation)

    describe "limit", ->
      headText = null
      paraText = null
      paraText2 = null
      para = null
      root = null

      beforeEach ->
        headText  = document.createTextNode("My Heading")
        paraText  = document.createTextNode("My paragraph")
        paraText2 = document.createTextNode(" continues")

        head = document.createElement('h1')
        head.appendChild(headText)
        para = document.createElement('p')
        para.appendChild(paraText)
        para.appendChild(paraText2)

        root = document.createElement('div')
        root.appendChild(head)
        root.appendChild(para)

      it "should exclude any nodes not within the bounding element.", ->
        range = new Range.NormalizedRange({
          commonAncestor: root
          start: headText
          end: paraText2
        })

        range = range.limit(para)
        expect(range.commonAncestor).toBe(para)
        expect(range.start).toBe(paraText)
        expect(range.end).toBe(paraText2)

      it "should return null if no nodes fall within the bounds", ->
        otherDiv = document.createElement('div')
        range = new Range.NormalizedRange({
          commonAncestor: root
          start: headText
          end: paraText2
        })
        expect(range.limit(otherDiv)).toBe(null)

    describe "toRange", ->
      it "should return a new Range object", ->
        mockRange =
          setStartBefore: jasmine.createSpy('Range#setStartBefore()')
          setEndAfter: jasmine.createSpy('Range#setEndAfter()')

        document.createRange = jasmine.createSpy('document.createRange()')
        document.createRange.andReturn(mockRange)
        r.toRange()

        expect(document.createRange).toHaveBeenCalled()
        expect(mockRange.setStartBefore).toHaveBeenCalled()
        expect(mockRange.setStartBefore).toHaveBeenCalledWith(r.start)
        expect(mockRange.setEndAfter).toHaveBeenCalled()
        expect(mockRange.setEndAfter).toHaveBeenCalledWith(r.end)
