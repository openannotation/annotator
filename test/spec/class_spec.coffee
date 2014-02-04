h = require('helpers')
Delegator = require('../../src/class')

class DelegatedExample extends Delegator
  events:
    'div click': 'pushA'
    'mousedown': 'pushB'
    'li click': 'pushC'
    'wibble': 'pushD'

  options:
    foo: "bar"
    bar: (a) -> a

  constructor: (elem) ->
    super
    @returns = []

  pushA: -> @returns.push("A")
  pushB: -> @returns.push("B")
  pushC: -> @returns.push("C")
  pushD: -> @returns.push("D")


describe 'Delegator', ->
  delegator = null
  $fix = null

  beforeEach ->
    h.addFixture('delegator')

    delegator = new DelegatedExample(h.fix())
    $fix = $(h.fix())

  afterEach -> h.clearFixtures()

  it "should provide access to an options object", ->
    assert.equal(delegator.options.foo, "bar")
    delegator.options.bar = (a) -> "<#{a}>"

  it "should be unique to an instance", ->
    assert.equal(delegator.options.bar("hello"), "hello")

  it "automatically binds events described in its events property", ->
    $fix.find('p').click()
    assert.deepEqual(delegator.returns, ['A'])

  it "will bind non-custom events to its root element if no selector is specified", ->
    $fix.trigger('mousedown')
    assert.deepEqual(delegator.returns, ['B'])

  it "will bind custom events to itself if no selector is specified", ->
    $fix.trigger('wibble')
    assert.deepEqual(delegator.returns, [])
    delegator.publish('wibble')
    assert.deepEqual(delegator.returns, ['D'])

  it "uses event delegation to bind the events", ->
    $fix.find('ol').append("<li>Hi there, I'm new round here.</li>")
    $fix.find('li').click()

    assert.deepEqual(delegator.returns, ['C', 'A', 'C', 'A'])

  it "should not bubble custom events", ->
    callback = sinon.spy()
    $('body').bind('custom', callback)

    delegator.element = $('<div />').appendTo('body')
    delegator.publish('custom')

    assert.isFalse(callback.called)

  it ".removeEvents() should remove all events previously bound by addEvents", ->
    delegator.removeEvents()

    $fix.find('ol').append("<li>Hi there, I'm new round here.</li>")
    $fix.find('li').click()
    $fix.trigger('baz')

    assert.deepEqual(delegator.returns, [])

  it ".subscribe() subscribes listeners", ->
    res = []
    delegator.subscribe('foo', -> res.push('bar'))
    assert.deepEqual(res, [])
    delegator.publish('foo')
    assert.deepEqual(res, ['bar'])

  it "passes args from .publish() to listeners", ->
    res = []
    delegator.subscribe('foo', (x, y, z) -> res.push(z, y, x))
    assert.deepEqual(res, [])
    delegator.publish('foo', [1, 2, 3])
    assert.deepEqual(res, [3, 2, 1])

  it "invokes the callback in the context of the object by default", ->
    res = null
    delegator.subscribe('foo', (-> res = this))
    delegator.publish('foo')
    assert.equal(res, delegator)

  it "invokes the callback with a context if provided", ->
    res = null
    sentinel = {}
    delegator.subscribe('foo', (-> res = this), sentinel)
    delegator.publish('foo')
    assert.equal(res, sentinel)

  it ".unsubscribe() unsubscribes listeners", ->
    res = []
    cbk = -> res.push('bar')
    delegator.subscribe('foo', cbk)
    delegator.unsubscribe('foo', cbk)
    delegator.publish('foo')
    assert.deepEqual(res, [])

  it ".unsubscribe() only unsubscribes listeners passed", ->
    res = []
    cbk = -> res.push('bar')
    delegator.subscribe('foo', -> res.push('baz'))
    delegator.subscribe('foo', cbk)
    delegator.unsubscribe('foo', cbk)
    delegator.publish('foo')
    assert.deepEqual(res, ['baz'])
