$ = jQuery

x = $(getFixture('annotator')).textNodes()

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

describe 'Annotator', ->
  a = null
  mockSelection = null

  beforeEach ->
    addFixture('annotator')

    a = new Annotator(fix(), {})

    mockSelection = (ii) -> new MockSelection(a.wrapper, testData[ii])

  afterEach ->
    delete a
    clearFixtures()

  # FIXME: Fails under Node. Need to mock out window.getSelection() properly
  it "loads selections from the window object on checkForSelection", ->
    sel = mockSelection(0)
    spyOn(window, 'getSelection').andReturn(sel)
    a.checkForEndSelection()
    expect(window.getSelection).toHaveBeenCalled()

  describe "deserializeRange", ->
    it "will deserialize a range composed of XPaths and offsets", ->
      deserialized = a.deserializeRange({
        start: "/p/strong"
        startOffset: 13
        end: "/p/strong"
        endOffset: 27
      })
      expect(textInNormedRange(deserialized)).toEqual("habitant morbi")

  describe "normRange", ->
    it "splits textNodes to generated a normed range", ->
      sel = mockSelection(0)
      normed = a.normRange(sel.getRangeAt(0))

      expect(normed.start).toBe(normed.end)
      expect(textInNormedRange(normed)).toEqual('habitant morbi')

    testFunction = (i) ->
      ->
        sel = mockSelection(i)
        normed = a.normRange(sel.getRangeAt(0))
        expect(textInNormedRange(normed)).toEqual(sel.expectation)

    # FIXME: testData[5] fails due to an apparent bug in jsdom. Specifically, the
    # textNode.splitText() method dumps half the result at the end of the container
    # element, which rather fuggers things.
    for i in [0...testData.length]
      it "should parse test range #{i} (#{testData[i][5]})", testFunction(i)

  describe "dumpAnnotations", ->
    it "returns false and prints a warning if no Store plugin is active", ->
      spyOn(console, 'warn')
      expect(a.dumpAnnotations()).toBeFalsy()
      expect(console.warn).toHaveBeenCalled()

    it "returns the results of the Store plugins dumpAnnotations method", ->
      a.plugins.Store = { dumpAnnotations: -> [1,2,3] }
      expect(a.dumpAnnotations()).toEqual([1,2,3])

  describe "addPlugin", ->

    Annotator.Plugins.Foo = -> this.name = "Bar"

    it "should add and instantiate a plugin of the specified name", ->
      a.addPlugin('Foo')
      expect(a.plugins['Foo'].name).toEqual('Bar')

    it "should complain if you try and instantiate a plugin twice", ->
      spyOn(console, 'error')
      a.addPlugin('Foo')
      a.addPlugin('Foo')
      expect(a.plugins['Foo'].name).toEqual('Bar')
      expect(console.error).toHaveBeenCalled()

    it "should complain if you try and instantiate a plugin that doesn't exist", ->
      spyOn(console, 'error')
      a.addPlugin('Bar')
      expect(a.plugins['Bar']?).toBeFalsy()
      expect(console.error).toHaveBeenCalled()