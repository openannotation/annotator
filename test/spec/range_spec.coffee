testData = [
  [ 0,           13,  0,           27,  "habitant morbi",                                    "Partial node contents." ]
  [ 0,           0,   0,           37,  "Pellentesque habitant morbi tristique",             "Full node contents, textNode refs." ]
  [ '/p/strong', 0,   '/p/strong', 1,   "Pellentesque habitant morbi tristique",             "Full node contents, elementNode refs." ]
  [ 0,           22,  1,           12,  "morbi tristique senectus et",                       "Spanning 2 nodes." ]
  [ '/p/strong', 0,   1,           12,  "Pellentesque habitant morbi tristique senectus et", "Spanning 2 nodes, elementNode start ref." ]
  [ 1,           165, '/p/em',     1,   "egestas semper. Aenean ultricies mi vitae est.",    "Spanning 2 nodes, elementNode end ref." ]
  [ 9,           7,   12,          11,  "Level 2\n\n\n  Lorem ipsum",                        "Spanning multiple nodes, textNode refs." ]
  [ '/p',        0,   '/p',        8,   "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. Donec non enim in turpis pulvinar facilisis. Ut felis.", "Spanning multiple nodes, elementNode refs." ]
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

    it "normalize() returns a normalized range", ->
      norm = r.normalize(fix())
      expect(norm instanceof Range.NormalizedRange).toBeTruthy()
      expect(textInNormedRange(norm)).toEqual("habitant morbi")

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
