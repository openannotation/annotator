Registry = require('../../src/registry')
AnnotationProvider = require('../../src/annotations')
StorageProvider = require('../../src/storage')


describe 'StorageProvider', ->
  a = null
  m = null
  r = null
  ann = null

  beforeEach ->
    r = new Registry()
      .include(AnnotationProvider)
      .include(StorageProvider)
    a = r['annotations']
    m = r['store']
    ann = {id: 123, some: 'data'}

  describe '#::configure()', ->

    it "should register the base storage implementation by default", ->
      assert.instanceOf(m, StorageProvider)

    it "should instantiate a provided implementation store settings", ->

      MockStore = sinon.spy()

      settings =
        store:
          type: MockStore
          foo: 'bar'

      r = new Registry(settings)
        .include(StorageProvider)
      assert(MockStore.calledWithNew(), 'instatiated MockStore')
      assert(MockStore.calledWith(settings.store), 'passed settings')

  describe '#update()', ->

    it "should pass annotation data to the store's #update()", ->
      sinon.spy(m, 'update')

      a.update(ann)
      assert(m.update.calledOnce, 'store .update() called once')
      assert(
        m.update.calledWith(ann),
        'store .update() called with correct args'
      )

    it "should return a promise resolving to the updated annotation", (done) ->
      a.update(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

  describe '#delete()', ->

    it "should pass annotation data to the store's #delete()", ->
      sinon.spy(m, 'delete')

      a.delete(ann)
      assert(m.delete.calledOnce, 'store .delete() called once')
      assert(
        m.delete.calledWith(ann),
        'store .delete() called with correct args'
      )

    it "should return a promise resolving to the deleted annotation object", (done) ->
      ann = {id: 123, some: 'data'}
      a.delete(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

  describe '#query()', ->

    it "should pass query data to the store's #query()", ->
      sinon.spy(m, 'query')

      a.query({foo: 'bar', type: 'giraffe'})
      assert(m.query.calledOnce, 'store .query() called once')
      assert(
        m.query.calledWith({foo: 'bar', type: 'giraffe'}),
        'store .query() called with correct args'
      )

      m.query.reset()

    it "should return a promise", (done) ->
      a.query({foo: 'bar', type: 'giraffe'})
        .done () ->
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

  describe '#load()', ->

    it "should pass query data to the store's #query()", ->
      sinon.spy(m, 'query')

      a.load({foo: 'bar', type: 'giraffe'})
      assert(m.query.calledOnce, 'store .query() called once')
      assert(
        m.query.calledWith({foo: 'bar', type: 'giraffe'}),
        'store .query() called with correct args'
      )

      m.query.reset()

    it "should return a promise", (done) ->
      a.load({foo: 'bar', type: 'giraffe'})
        .done () ->
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))
