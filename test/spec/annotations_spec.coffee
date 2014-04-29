Events = require('../../src/events')
AnnotationRegistry = require('../../src/annotations')
NullStore = require('../../src/plugin/nullstore')
$ = require('../../src/util').$


describe 'AnnotationRegistry', ->
  a = null
  s = null

  beforeEach ->
    s = new NullStore()
    core = {}
    Events.mixin(core)
    a = new AnnotationRegistry(core, s)

    sinon.spy(s, 'create')
    sinon.spy(s, 'update')
    sinon.spy(s, 'delete')
    sinon.spy(s, 'query')

  describe '#create()', ->

    it "should pass annotation data to the store's #create()", (done) ->

      a.create({some: 'data'})
      .then ->
        assert(s.create.calledOnce, 'store .create() called once')
        assert(
          s.create.calledWith(sinon.match({some: 'data'})),
          'store .create() called with correct args'
        )
      .then(done, done)

    it "should return a promise resolving to the created annotation", (done) ->
      ann = {some: 'data'}
      a.create(ann)
      .then (ret) ->
        assert.equal(ret, ann)
        assert.property(ret, 'id', 'created annotation has an id')
      .then(done, done)

  describe '#update()', ->

    it "should pass annotation data to the store's #update()", (done) ->

      a.update({id: '123', some: 'data'})
      .then ->
        assert(s.update.calledOnce, 'store .update() called once')
        assert(
          s.update.calledWith(sinon.match({id: '123', some: 'data'})),
          'store .update() called with correct args'
        )
      .then(done, done)

    it "should throw a TypeError if the data lacks an id", ->
      ann = {some: 'data'}
      assert.throws((-> a.update(ann)), TypeError, ' id ')

  describe '#delete()', ->

    it "should pass annotation data to the store's #delete()", (done) ->

      a.delete({id: '123', some: 'data'})
      .then ->
        assert(s.delete.calledOnce, 'store .delete() called once')
        assert(
          s.delete.calledWith(sinon.match({id: '123', some: 'data'})),
          'store .delete() called with correct args'
        )
      .then(done, done)

    it "should throw a TypeError if the data lacks an id", ->
      ann = {some: 'data'}
      assert.throws((-> a.delete(ann)), TypeError, ' id ')

  describe '#query()', ->

    it "should invoke the query method on the registered store service", ->
      query = {url: 'foo'}
      a.query(query)
      assert(s.query.calledWith(query))

  # I've removed a nasty test of implementation (testing _cycle directly, eurgh)
  # and this is here as a note to check the implementation strips
  # non-serialisable data before passing stuff to the store plugin.
  xit "should strip any _local data before passing to the store plugin"
