$ = jQuery

class DelegatedExample extends Delegator
  events:
    'div click': 'pushA'
    'baz': 'pushB'

  constructor: (elem) ->
    super
    @returns = []
    this.addEvents()

  pushA: -> @returns.push("A")
  pushB: -> @returns.push("B")
  pushC: -> @returns.push("C")

describe 'DelegatorClass', ->
  d = null
  $fix = null

  beforeEach ->
    addFixture('delegatorclass')

    d = new DelegatedExample(fix())
    $fix = $(fix())

  afterEach -> clearFixtures()

  describe "addEvent", ->
    it "adds an event for a selector", ->
      d.addEvent('p', 'foo', 'pushC')

      $fix.find('p').trigger('foo')
      expect(d.returns).toEqual(['C'])

    it "adds an event for an element", ->
      d.addEvent($fix.find('p').get(0), 'bar', 'pushC')

      $fix.find('p').trigger('bar')
      expect(d.returns).toEqual(['C'])

    it "uses event delegation to bind the events", ->
      d.addEvent('li', 'click', 'pushB')

      $fix.find('ol').append("<li>Hi there, I'm new round here.</li>")
      $fix.find('li').click()

      expect(d.returns).toEqual(['B', 'A', 'B', 'A'])

  it "automatically binds events described in its events property", ->
    $fix.find('p').click()
    expect(d.returns).toEqual(['A'])

  it "will bind events in its events property to its root element if no selector is specified", ->
    $fix.trigger('baz')
    expect(d.returns).toEqual(['B'])