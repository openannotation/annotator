Registry = require('../../src/registry')
AnnotationProvider = require('../../src/annotations')


describe 'AnnotationProvider', ->
  a = null
  r = null
  m = null

  beforeEach ->
    r = new Registry()
      .include(AnnotationProvider)

    a = r['annotations']
    m = r['store']

    sinon.spy(m, 'create')
    sinon.spy(m, 'update')
    sinon.spy(m, 'delete')
    sinon.spy(m, 'query')

  describe '#create()', ->

    it "should pass annotation data to the store's #create()", ->

      a.create({some: 'data'})
      assert(m.create.calledOnce, 'store .create() called once')
      assert(
        m.create.calledWith(sinon.match({some: 'data'})),
        'store .create() called with correct args'
      )

    it "should return a promise resolving to the created annotation", (done) ->
      ann = {some: 'data'}
      a.create(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          assert.property(ret, 'id', 'created annotation has an id')
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

  describe '#update()', ->

    it "should pass annotation data to the store's #update()", ->

      a.update({id: '123', some: 'data'})
      assert(m.update.calledOnce, 'store .update() called once')
      assert(
        m.update.calledWith(sinon.match({id: '123', some: 'data'})),
        'store .update() called with correct args'
      )

    it "should throw a TypeError if the data lacks an id", ->
      ann = {some: 'data'}
      assert.throws((-> a.update(ann)), TypeError, ' id ')

  describe '#delete()', ->

    it "should pass annotation data to the store's #delete()", ->

      a.delete({id: '123', some: 'data'})
      assert(m.delete.calledOnce, 'store .delete() called once')
      assert(
        m.delete.calledWith(sinon.match({id: '123', some: 'data'})),
        'store .delete() called with correct args'
      )

    it "should throw a TypeError if the data lacks an id", ->
      ann = {some: 'data'}
      assert.throws((-> a.delete(ann)), TypeError, ' id ')

  describe '#query()', ->

    it "should invoke the query method on the registered store service", ->
      query = {url: 'foo'}
      a.query(query)
      assert(m.query.calledWith(query))

  describe '#load()', ->

    it "should call the query method", ->
      sinon.spy(a, 'query')
      a.load({foo: 'bar', type: 'giraffe'})
      assert(a.query.calledWith, sinon.match({foo: 'bar', type: 'giraffe'}))

  describe '#_cycle()', ->
    store_noop = (a) -> $.Deferred().resolve(a).promise()
    local = null
    ann = null

    beforeEach ->
      local = {foo: 'bar', numbers: [1,2,3]}
      ann = {some: 'data', _local: local}
      m['bogus'] = sinon.spy(store_noop)

    it "should strip an annotation of any _local before passing to the store", ->
      a._cycle(ann, 'bogus')
      assert(
        m.bogus.calledWith(sinon.match({some: 'data'}))
        'annotation _local stripped before store call'
      )
    it "should pass annotation data to the store method", ->
      a._cycle(ann, 'bogus')
      assert(m.bogus.calledOnce, 'store method called once')
      assert(
        m.bogus.calledWith(sinon.match({some: 'data'})),
        'store method called with correct args'
      )

    it "should reattach _local after the store promise resolves", (done) ->
       after = sinon.spy (ret) ->
        after.calledWith(sinon.match({some: 'data', _local: local}))
        done()

       a._cycle(ann, 'bogus').done(after)
