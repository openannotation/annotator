h = require('helpers')
Util = require('../../src/util')
$ = Util.$

describe 'Util.contains()', ->
  it 'should return true when called on itself', ->
    text = document.createTextNode "This is a test text"

    # This would be the trivial solution, but this fails with PhantomJS,
    # because PhantomJS returns false for x.contains(x)
    #
    # But this is wrong, see the specs here:
    #  https://developer.mozilla.org/en-US/docs/Web/API/Node.contains
    #  http://www.w3.org/TR/domcore/#dom-node-contains

    # assert.isTrue(text.contains text)

    # This is why we have to use this override
    assert.isTrue(Util.contains(text, text))

  it 'should return false on independent elements', ->
    div1 = document.createElement "div"
    div2 = document.createElement "div"
    assert.isFalse Util.contains div1, div2

  it 'should return true on immediate children, but not on parent', ->
    div1 = document.createElement "div"
    div2 = document.createElement "div"
    div1.appendChild div2
    assert.isTrue Util.contains div1, div2
    assert.isFalse Util.contains div2, div1

  it 'should return true on grand-children, but not on grand-parent', ->
    div1 = document.createElement "div"
    div2 = document.createElement "div"
    div3 = document.createElement "div"
    div1.appendChild div2
    div2.appendChild div3
    assert.isTrue Util.contains div1, div3
    assert.isFalse Util.contains div3, div1

describe 'Util.flatten()', ->
  it "flattens the contents of an Array", ->
    flattened = Util.flatten([[1,2], 'lorem ipsum', [{}]])
    assert.deepEqual(flattened, [1, 2, 'lorem ipsum', {}])

describe 'Util.getTextNodes()', ->
  $fix = null

  beforeEach ->
    h.addFixture 'textnodes'
    $fix = $(h.fix())

  afterEach -> h.clearFixtures()

  it "returns an element's textNode descendants", ->
    nodes = Util.getTextNodes($fix)
    text = (node.nodeValue for node in nodes)

    expectation = [ '\n  '
                  , 'lorem ipsum'
                  , '\n  '
                  , 'dolor sit'
                  , '\n'
                  , '\n'
                  , 'dolor sit '
                  , 'amet'
                  , '. humpty dumpty. etc.'
                  ]

    assert.deepEqual(text, expectation)

  it "returns an empty jQuery collection when called in undefined node", ->
    result = Util.getTextNodes($(undefined))
    assert.instanceOf(result, $)
    assert.lengthOf(result, 0)

  it "returns an element's TextNodes after Text.splitText() text has been called", ->
    # Build a very csutom fixture to replicate an issue in IE9 where calling
    # split text on an text node does not update the parents .childNodes value
    # which continues to return the unsplit text node.
    fixture = document.getElementById('fixtures') || $('body')[0]
    fixture.innerHTML = ''

    para = document.createElement('p')
    text = document.createTextNode('this is a paragraph of text')
    para.appendChild(text)
    fixture.appendChild(para)

    assert.lengthOf(para.childNodes, 1)
    first = text.splitText(14)

    # Some basic assertions on the split text.
    assert.equal(first.nodeValue, 'graph of text')
    assert.equal(text.nodeValue, 'this is a para')
    assert.equal(para.firstChild.nodeValue, 'this is a para')
    assert.equal(para.lastChild.nodeValue, 'graph of text')

    # JSDom will only correctly return .text() contents after checking the
    # length of the para.childNodes object. IE9 will only returnt the contents
    # of the first node.
    # assert.equal($(para).text(), 'this is a paragraph of text')

    # Both of the following tests fail in IE9 so we cannot rely on the
    # Text.childNodes property or jQuery.fn.contents() to retrieve the text
    # nodes.
    # assert.lengthOf(para.childNodes, 2)
    # assert.lengthOf($(para).contents(), 2)

    assert.lengthOf(Util.getTextNodes($(para)), 2)

describe 'Util.escape()', ->
  it "should escape any HTML special characters into entities", ->
    assert.equal(Util.escape('<>"&'), '&lt;&gt;&quot;&amp;')

describe 'Util.uuid()', ->
  it "should return a unique id on each call", ->
    counter = 100
    results = []

    while counter--
      current = Util.uuid()
      assert.equal(results.indexOf(current), -1)
      results.push current

describe 'Util.preventEventDefault()', ->
  it "should call prevent default if the method exists", ->
    event = {preventDefault: sinon.spy()}
    Util.preventEventDefault(event)
    assert(event.preventDefault.calledOnce)

    assert.doesNotThrow((-> Util.preventEventDefault(1)), Error)
    assert.doesNotThrow((-> Util.preventEventDefault(null)), Error)
    assert.doesNotThrow((-> Util.preventEventDefault(undefined)), Error)
