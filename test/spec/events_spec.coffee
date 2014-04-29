Events = require('../../src/events')
Promise = require('../../src/util').Promise

describe 'Events', ->

  t = null

  beforeEach ->
    t = {}
    Events.mixin(t)

  describe 'triggerThen', ->

    it 'should return a promise which is fulfilled when all event handlers have
        been fired', (done) ->
      out = []

      t.on('foo', -> out.push('a'))
      t.on('foo', -> out.push('b'))

      t.triggerThen('foo')
      .then ->
        assert.deepEqual(['a', 'b'], out.sort())
        done()

    it 'should return a promise which is fulfilled when all promises returned by
        event handlers have been resolved', (done) ->
      out = []
      resolver1 = null
      resolver2 = null

      p1 = new Promise((resolve, reject) -> resolver1 = resolve)
      p2 = new Promise((resolve, reject) -> resolver2 = resolve)
      t.on('foo', -> p1)
      t.on('foo', -> p2)

      t.triggerThen('foo')
      .then ->
        assert.deepEqual(['a', 'b'], out)
        done()

      out.push('a')
      resolver1()
      out.push('b')
      resolver2()

    it 'should return a promise which is rejected when a promise returned by an
        event handler is rejected', (done) ->
      out = []
      resolver = null
      rejecter = null

      p1 = new Promise((resolve, reject) -> resolver = resolve)
      p2 = new Promise((resolve, reject) -> rejecter = reject)
      t.on('foo', -> p1)
      t.on('foo', -> p2)

      p = t.triggerThen('foo')
      p.catch ->
        assert.deepEqual(['a', 'b'], out)
        done()
      p.then ->
        done(new Error('Should have rejected this promise!'))

      out.push('a')
      resolver()
      out.push('b')
      rejecter()

    it 'should return a promise which is rejected when an event handler
        throws an error', (done) ->
      out = []

      t.on('foo', -> console.log(i.do.not.exist))

      p = t.triggerThen('foo')
      p.catch ->
        done()
      p.then ->
        done(new Error('Should have rejected this promise!'))

    it 'should trigger the magic "all" listener', (done) ->
      out = []

      t.on('all', -> out.push('a'))
      t.on('foo', -> out.push('b'))

      t.triggerThen('foo')
      .then ->
        assert.deepEqual(['a', 'b'], out.sort())
        done()
