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
  [ "/div/text()[2]",0,"/div/text()[2]",28,"Lorem sed do eiusmod tempor.",                   "Text between br tags, textNode refs"]
  [ "/div/text()[2]",0,"/div",     4,"Lorem sed do eiusmod tempor.",                         "Text between br tags, elementNode ref at end"]
  [ "/div/text()[2]",0,"/div",     5,"Lorem sed do eiusmod tempor.",                         "Text between br tags, with <br/> at end"]
  [ "/div/text()[2]",0,"/div",     6,"Lorem sed do eiusmod tempor.",                         "Text between br tags, with <br/><br/> at end"]
  [ "/div/text()[2]",0,"/div",     7,"Lorem sed do eiusmod tempor.",                         "Text between br tags, with <br/><br/><br/> at end"]
  [ "/div",      3,"/div/text()[2]",28,"Lorem sed do eiusmod tempor.",                       "Text between br tags, elementNode ref at start"]
  [ "/div",      2,"/div/text()[2]",28,"Lorem sed do eiusmod tempor.",                       "Text between br tags, with <br/> at start"]
  [ "/div",      1,"/div/text()[2]",28,"Lorem sed do eiusmod tempor.",                       "Text between br tags, with <br/><br/> at start"]
  [ "/div[2]/text()[2]",0,"/div[2]/text()[2]",28,"Lorem sed do eiusmod tempor.",             "Text between br tags, textNode refs"]
  [ "/div[2]/text()[2]",0,"/div[2]",4,"Lorem sed do eiusmod tempor.",                        "Text between br tags, elementNode ref at end"]
  [ "/div[2]/text()[2]",0,"/div[2]",5,"Lorem sed do eiusmod tempor.",                        "Text between br tags, with <br/> at end"]
  [ "/div[2]/text()[2]",0,"/div[2]",6,"Lorem sed do eiusmod tempor.",                        "Text between br tags, with <br/><p><br/></p> at end"]
  [ "/div[2]/text()[2]",0,"/div[2]",7,"Lorem sed do eiusmod tempor.",                        "Text between br tags, with <br/><p><br/></p><br/> at end"]
  [ "/div[2]",   3,"/div[2]/text()[2]",28,"Lorem sed do eiusmod tempor.",                    "Text between br tags, elementNode ref at start"]
  [ "/div[2]",   2,"/div[2]/text()[2]",28,"Lorem sed do eiusmod tempor.",                    "Text between br tags, with <p><br/></p> at the start"]
  [ "/div[2]",   1,"/div[2]/text()[2]",28,"Lorem sed do eiusmod tempor.",                    "Text between br tags, with <br/><p><br/></p> at the start"]
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

  describe ".nodeFromXPath()", ->
    xpath = if window.require then "/html/body/p/strong" else "/html/body/div/p/strong"
    it "should parse a standard xpath string", ->
      node = Range.nodeFromXPath xpath
      assert.equal(node, $('strong')[0])

    it "should parse an standard xpath string for an xml document", ->
      Annotator.$.isXMLDoc = -> true
      node = Range.nodeFromXPath xpath
      assert.equal(node, $('strong')[0])

  describe "SerializedRange", ->
    beforeEach ->
        
      # This is needed so that we can read ranges via selection API  
      $(fix()).show()

      r = new Range.SerializedRange
        start: "/p/strong"
        startOffset: 13
        end: "/p/strong"
        endOffset: 27

    afterEach ->
      $(fix()).hide()        

    describe "normalize", ->
      it "should return a normalized range", ->
        norm = r.normalize(fix())
        assert.isTrue(norm instanceof Range.NormalizedRange)
        assert.equal(norm.text(), "habitant morbi")

      it "should return a normalized range with 0 offsets", ->
        r.startOffset = 0
        norm = r.normalize(fix())
        assert.isTrue(norm instanceof Range.NormalizedRange)
        assert.equal(norm.text(), "Pellentesque habitant morbi")

      it "should always find the right text elements, based on offset", ->

        # Create a normalized range to find the text node.
        # This will split text nodes.
        norm = r.normalize fix()

        # We should get the usual text
        assert.equal(norm.start.data, "habitant morbi")
        assert.equal(norm.text(), "habitant morbi")
        assert.equal(Util.readRangeViaSelection(norm), "habitant morbi")

        # Now let's insert a <hr /> tag before and after the text node!
        # (Since the <hr /> tag is not a text node, this should not change
        # the text nodes and their offsets.)
        hr1 = document.createElement "hr"
        hr2 = document.createElement "hr"
        norm.start.parentNode.insertBefore hr1, norm.start
        norm.start.parentNode.insertBefore hr2, norm.start.nextSibling

        # Now let's try to normalize the same range again,
        # this time working with the text nodes already split by last action
        norm = r.normalize fix()

        # We should get the same text as last time:
        assert.equal(Util.readRangeViaSelection(norm), "habitant morbi")
        assert.equal(norm.text(), "habitant morbi")

      it "should raise Range.RangeError if it cannot normalize the range", ->
        check = false
        try
          r.normalize($('<div/>')[0])
        catch e
          if e instanceof Range.RangeError
            check = true

        assert.isTrue(check)

    it "serialize() returns a serialized range", ->
      seri = r.serialize(fix())
      assert.equal(seri.start, "/p[1]/strong[1]")
      assert.equal(seri.startOffset, 13)
      assert.equal(seri.end, "/p[1]/strong[1]")
      assert.equal(seri.endOffset, 27)
      assert.isTrue(seri instanceof Range.SerializedRange)

    it "toObject() returns a simple object", ->
      obj = r.toObject()
      assert.equal(obj.start, "/p/strong")
      assert.equal(obj.startOffset, 13)
      assert.equal(obj.end, "/p/strong")
      assert.equal(obj.endOffset, 27)
      assert.equal(JSON.stringify(obj), '{"start":"/p/strong","startOffset":13,"end":"/p/strong","endOffset":27}')

  describe "BrowserRange", ->
    beforeEach ->
      sel = mockSelection(0)
      r = new Range.BrowserRange(sel.getRangeAt(0))

    it "normalize() returns a normalized range", ->
      norm = r.normalize()
      assert.equal(norm.start, norm.end)
      assert.equal(textInNormedRange(norm), 'habitant morbi')

    testBrowserRange = (i) ->
      ->
        sel   = mockSelection(i)
        range = new Range.BrowserRange(sel.getRangeAt(0))
        norm  = range.normalize(fix())

        assert.equal(textInNormedRange(norm), sel.expectation)

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

      assert.equal($.type(textNodes), 'array')
      assert.lengthOf(textNodes, sel.endOffset)

      # Should contain the contents of the first <strong> element.
      assert.equal(textNodes[0].nodeValue, 'Pellentesque habitant morbi tristique')

    it "text() returns the textual contents of the range", ->
      assert.equal(r.text(), sel.expectation)

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
        assert.equal(range.commonAncestor, para)
        assert.equal(range.start, paraText)
        assert.equal(range.end, paraText2)

      it "should return null if no nodes fall within the bounds", ->
        otherDiv = document.createElement('div')
        range = new Range.NormalizedRange({
          commonAncestor: root
          start: headText
          end: paraText2
        })
        assert.equal(range.limit(otherDiv), null)

    describe "toRange", ->
      it "should return a new Range object", ->
        mockRange =
          setStartBefore: sinon.spy()
          setEndAfter: sinon.spy()

        sinon.stub(document, 'createRange').returns(mockRange)
        r.toRange()

        assert(document.createRange.calledOnce)
        assert(mockRange.setStartBefore.calledOnce)
        assert.isTrue(mockRange.setStartBefore.calledWith(r.start))
        assert(mockRange.setEndAfter.calledOnce)
        assert.isTrue(mockRange.setEndAfter.calledWith(r.end))

        document.createRange.restore()
