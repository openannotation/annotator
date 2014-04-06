AnnotationRegistry = require('../../src/annotations')
NullStore = require('../../src/nullstore')
$ = require('../../src/util').$


describe 'AnnotationRegistry', ->
  a = null
  s = null

  beforeEach ->
    s = new NullStore()

    a = new AnnotationRegistry()
    a.configure(core: {store: s})

    sinon.spy(s, 'create')
    sinon.spy(s, 'update')
    sinon.spy(s, 'delete')
    sinon.spy(s, 'query')

  describe '#create()', ->

    it "should pass annotation data to the store's #create()", ->

      a.create({some: 'data'})
      assert(s.create.calledOnce, 'store .create() called once')
      assert(
        s.create.calledWith(sinon.match({some: 'data'})),
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
      assert(s.update.calledOnce, 'store .update() called once')
      assert(
        s.update.calledWith(sinon.match({id: '123', some: 'data'})),
        'store .update() called with correct args'
      )

    it "should throw a TypeError if the data lacks an id", ->
      ann = {some: 'data'}
      assert.throws((-> a.update(ann)), TypeError, ' id ')

  describe '#delete()', ->

    it "should pass annotation data to the store's #delete()", ->

      a.delete({id: '123', some: 'data'})
      assert(s.delete.calledOnce, 'store .delete() called once')
      assert(
        s.delete.calledWith(sinon.match({id: '123', some: 'data'})),
        'store .delete() called with correct args'
      )

    it "should throw a TypeError if the data lacks an id", ->
      ann = {some: 'data'}
      assert.throws((-> a.delete(ann)), TypeError, ' id ')

  describe '#query()', ->

    it "should invoke the query method on the registered store service", ->
      query = {url: 'foo'}
      a.query(query)
      assert(s.query.calledWith(query))

  describe '#_cycle()', ->
    store_noop = (a) -> $.Deferred().resolve(a).promise()
    local = null
    ann = null

    beforeEach ->
      local = {foo: 'bar', numbers: [1,2,3]}
      ann = {some: 'data', _local: local}
      s['bogus'] = sinon.spy(store_noop)

    it "should strip an annotation of any _local before passing to the store", ->
      a._cycle(ann, 'bogus')
      assert(
        s.bogus.calledWith(sinon.match({some: 'data'}))
        'annotation _local stripped before store call'
      )
    it "should pass annotation data to the store method", ->
      a._cycle(ann, 'bogus')
      assert(s.bogus.calledOnce, 'store method called once')
      assert(
        s.bogus.calledWith(sinon.match({some: 'data'})),
        'store method called with correct args'
      )

    it "should reattach _local after the store promise resolves", (done) ->
       after = sinon.spy (ret) ->
        after.calledWith(sinon.match({some: 'data', _local: local}))
        done()

       a._cycle(ann, 'bogus').done(after)
