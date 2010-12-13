;(function () {

var x = $(getFixture('annotator')).textNodes()
var testData = [[ 0,           13,  0,           27,  "habitant morbi",                                    "Partial node contents." ]
               ,[ 0,           0,   0,           37,  "Pellentesque habitant morbi tristique",             "Full node contents, textNode refs." ]
               ,[ '/p/strong', 0,   '/p/strong', 1,   "Pellentesque habitant morbi tristique",             "Full node contents, elementNode refs." ]
               ,[ 0,           22,  1,           12,  "morbi tristique senectus et",                       "Spanning 2 nodes." ]
               ,[ '/p/strong', 0,   1,           12,  "Pellentesque habitant morbi tristique senectus et", "Spanning 2 nodes, elementNode start ref." ]
               ,[ 1,           165, '/p/em',     1,   "egestas semper. Aenean ultricies mi vitae est.",    "Spanning 2 nodes, elementNode end ref." ]
               ,[ 9,           7,   12,          11,  "Level 2\n\n\n  Lorem ipsum",                "Spanning multiple nodes, textNode refs." ]
               ,[ '/p',        0,   '/p',        8,   "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. Donec non enim in turpis pulvinar facilisis. Ut felis.", "Spanning multiple nodes, elementNode refs." ]]

describe('Annotator', function () {
  var a
  var mockSelection

  beforeEach(function () {
    addFixture('annotator')

    a = new Annotator({}, fix())

    mockSelection = function (ii) {
      return new MockSelection(a.wrapper, testData[ii])
    }
  })

  afterEach(function () {
    delete a
    clearFixtures()
  })

  it("loads selections from the window object on checkForSelection", function () {
    var sel = mockSelection(0)
    spyOn(window, 'getSelection').andReturn(sel)
    a.checkForEndSelection()
    expect(window.getSelection).toHaveBeenCalled()
  })

  it('will deserialize a range composed of XPaths and offsets', function () {
    var deserialized = a.deserializeRange({
      start: "/p/strong",
      startOffset: 13,
      end: "/p/strong",
      endOffset: 27
    })

    expect(textInNormedRange(deserialized)).toEqual("habitant morbi")
  })

  it('splits textNodes to generated a normed range', function () {
    var sel = mockSelection(0)
    var normed = a.normRange(sel.getRangeAt(0))

    expect(normed.start).toBe(normed.end)
    expect(textInNormedRange(normed)).toEqual('habitant morbi')
  })

  var testFunction = function (i) {
    return function () {
      var sel = mockSelection(i)

      var normed = a.normRange(sel.getRangeAt(0))
      expect(textInNormedRange(normed)).toEqual(sel.expectation)
    }
  }

  for(var i = 0; i < testData.length; i += 1) {
    it('#normRange should parse test range ' + i + ' (' + testData[i][5] + ')', testFunction(i))
  }

})

})()
