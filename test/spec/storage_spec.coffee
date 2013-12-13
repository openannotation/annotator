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

    it "should instantiate a provided implementation with store settings", ->

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

    it "should return a promise resolving to the updated annotation", (done) ->
      a.update(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

  describe '#delete()', ->

    it "should return a promise resolving to the deleted annotation object", (done) ->
      ann = {id: 123, some: 'data'}
      a.delete(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

  describe '#query()', ->

    it "should return a promise resolving to the results and metadata", (done) ->
      a.query({foo: 'bar', type: 'giraffe'})
        .done (res, meta) ->
          assert.isArray(res)
          assert.isObject(meta)
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))
