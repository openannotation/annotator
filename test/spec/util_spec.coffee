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
    flattened = Util.flatten([[1,2], 'lorem ipsum', [{}, null, [], undefined]])
    assert.deepEqual(flattened, [1, 2, 'lorem ipsum', {}, null, undefined])

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
