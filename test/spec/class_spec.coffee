describe 'Evented', ->
  e = null

  beforeEach -> e = new Evented()
  afterEach -> e = null

  it ".subscribe() subscribes listeners", ->
    res = []
    e.subscribe('foo', -> res.push('bar'))
    assert.deepEqual(res, [])
    e.publish('foo')
    assert.deepEqual(res, ['bar'])

  it "passes args from .publish() to listeners", ->
    res = []
    e.subscribe('foo', (x, y, z) -> res.push(z, y, x))
    assert.deepEqual(res, [])
    e.publish('foo', [1, 2, 3])
    assert.deepEqual(res, [3, 2, 1])

  it ".unsubscribe() unsubscribes listeners", ->
    res = []
    cbk = -> res.push('bar')
    e.subscribe('foo', cbk)
    e.unsubscribe('foo', cbk)
    e.publish('foo')
    assert.deepEqual(res, [])

  it ".unsubscribe() only unsubscribes listeners passed", ->
    res = []
    cbk = -> res.push('bar')
    e.subscribe('foo', -> res.push('baz'))
    e.subscribe('foo', cbk)
    e.unsubscribe('foo', cbk)
    e.publish('foo')
    assert.deepEqual(res, ['baz'])


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
    addFixture('delegator')

    delegator = new DelegatedExample(fix())
    $fix = $(fix())

  afterEach -> clearFixtures()

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

  it ".on() should be an alias of .subscribe()", ->
    assert.strictEqual(delegator.on, delegator.subscribe)
