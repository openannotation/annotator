var DelegatedExample = DelegatorClass.extend({
  events: {
    'div click': 'pushA',
    'baz': 'pushB'
  },

  init: function (elem, ret) {
    var self = this

    this.element = elem
    this.returns = ret

    _(['A', 'B', 'C']).each(function (val) {
      self['push' + val] = function () { self.returns.push(val) }
    })

    this._super()
  }
})

describe('DelegatorClass', function () {
  var d
  var $fix

  beforeEach(function () {
    addFixture('delegatorclass')

    d = new DelegatedExample(fix(), [])
    $fix = $(fix())
  })

  afterEach(function () {
    clearFixtures()
  })

  describe('addDelegatedEvent', function () {
    it('adds an event for a selector', function () {
      d.addDelegatedEvent('p', 'foo', 'pushC')

      $fix.find('p').trigger('foo')
      expect(d.returns).toEqual(['C'])
    })

    it('adds an event for an element', function () {
      d.addDelegatedEvent($fix.find('p').get(0), 'bar', 'pushC')

      $fix.find('p').trigger('bar')
      expect(d.returns).toEqual(['C'])
    })

    it('uses event delegation to bind the events', function () {
      d.addDelegatedEvent('li', 'click', 'pushB')

      $fix.find('ol').append("<li>Hi there, I'm new round here.</li>")
      $fix.find('li').click()

      expect(d.returns).toEqual(['B', 'A', 'B', 'A'])
    })
  })

  it('automatically binds events described in its events property', function () {
    $fix.find('p').click()
    expect(d.returns).toEqual(['A'])
  })

  it('will bind events in its events property to its root element if no selector is specified', function () {
    $fix.trigger('baz')
    expect(d.returns).toEqual(['B'])
  })

})