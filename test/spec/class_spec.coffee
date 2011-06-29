class DelegatedExample extends Delegator
  events:
    'div click': 'pushA'
    'baz': 'pushB'

  options:
    foo: "bar"
    bar: (a) -> a

  constructor: (elem) ->
    super
    @returns = []

  pushA: -> @returns.push("A")
  pushB: -> @returns.push("B")
  pushC: -> @returns.push("C")

describe 'Delegator', ->
  delegator = null
  $fix = null

  beforeEach ->
    addFixture('delegator')

    delegator = new DelegatedExample(fix())
    $fix = $(fix())

  afterEach -> clearFixtures()

  describe "options", ->
    it "should provide access to an options object", ->
      expect(delegator.options.foo).toEqual("bar")
      delegator.options.bar = (a) -> "<#{a}>"

    it "should be unique to an instance", ->
      expect(delegator.options.bar("hello")).toEqual("hello")

  describe "addEvent", ->
    it "adds an event for a selector", ->
      delegator.addEvent('p', 'foo', 'pushC')

      $fix.find('p').trigger('foo')
      expect(delegator.returns).toEqual(['C'])

    it "adds an event for an element", ->
      delegator.addEvent($fix.find('p').get(0), 'bar', 'pushC')

      $fix.find('p').trigger('bar')
      expect(delegator.returns).toEqual(['C'])

    it "uses event delegation to bind the events", ->
      delegator.addEvent('li', 'click', 'pushB')

      $fix.find('ol').append("<li>Hi there, I'm new round here.</li>")
      $fix.find('li').click()

      expect(delegator.returns).toEqual(['B', 'A', 'B', 'A'])

  it "automatically binds events described in its events property", ->
    $fix.find('p').click()
    expect(delegator.returns).toEqual(['A'])

  it "will bind events in its events property to its root element if no selector is specified", ->
    $fix.trigger('baz')
    expect(delegator.returns).toEqual(['B'])

  describe "on", ->
    it "should be an alias of Delegator#subscribe()", ->
      expect(delegator.on).toEqual(delegator.subscribe)

  describe "subscribe", ->
    it "should bind an event to the Delegator#element", ->
      callback = jasmine.createSpy('listener')
      delegator.subscribe('custom', callback)
      
      delegator.element.trigger('custom')
      expect(callback).toHaveBeenCalled()

    it "should remove the event object from the parameters passed to the callback", ->
      callback = jasmine.createSpy('listener')
      delegator.subscribe('custom', callback)

      delegator.element.trigger('custom', ['first', 'second', 'third'])
      expect(callback).toHaveBeenCalledWith('first', 'second', 'third')

    it "should ensure the bound function is unbindable", ->
      callback = jasmine.createSpy('listener')

      delegator.subscribe('custom', callback)
      delegator.unsubscribe('custom', callback)
      delegator.publish('custom')

      expect(callback).not.toHaveBeenCalled()

    it "should not bubble custom events", ->
      callback = jasmine.createSpy('listener')
      $('body').bind('custom', callback)

      delegator.element = $('<div />').appendTo('body')
      delegator.publish('custom')

      expect(callback).not.toHaveBeenCalled()

  describe "unsubscribe", ->
    it "should unbind an event from the Delegator#element", ->
      callback = jasmine.createSpy('listener')

      delegator.element.bind('custom', callback)
      delegator.unsubscribe('custom', callback)
      delegator.element.trigger('custom')

      expect(callback).not.toHaveBeenCalled()
      
      callback = jasmine.createSpy('second listener')

      delegator.element.bind('custom', callback)
      delegator.unsubscribe('custom')
      delegator.element.trigger('custom')

      expect(callback).not.toHaveBeenCalled()

    describe "publish", ->
      it "should trigger an event on the Delegator#element", ->
        callback = jasmine.createSpy('listener')
        delegator.element.bind('custom', callback)

        delegator.publish('custom')
        expect(callback).toHaveBeenCalled()

    describe "isCustomEvent", ->
      events = [
        ['click', false]
        ['mouseover', false]
        ['mousedown', false]
        ['submit', false]
        ['load', false]
        ['click.namespaced', false]
        ['save', true]
        ['cancel', true]
        ['update', true]
      ]        

      it "should return true if the string passed is a custom event", ->
        while events.length
          [event, result] = events.shift()
          expect(delegator.isCustomEvent(event)).toEqual(result)
