Storage = require('../../../src/storage')
{$, Promise} = require('../../../src/util')

class MockHookRunner

  constructor: ->
    @calls = []

  runHook: (name, args) =>
    @calls.push({name: name, args: args})
    return Promise.resolve()


class MockStorage

  create: (annotation) ->
    annotation.stored = true
    this._record('create')
    return annotation

  update: (annotation) ->
    annotation.stored = true
    this._record('update')
    return annotation

  delete: (annotation) ->
    annotation.stored = true
    this._record('delete')
    return annotation

  query: (queryObj) ->
    this._record('query')
    return [[], {total: 0}]

  # Just a little helper to make sure hooks fire in the right order
  _record: (name) ->
    if typeof @_callRecorder == 'function'
      @_callRecorder(name)

class FailingMockStorage

  create: (annotation) ->
    return Promise.reject("failure message")

  update: (annotation) ->
    return Promise.reject("failure message")

  delete: (annotation) ->
    return Promise.reject("failure message")

  query: (queryObj) ->
    return Promise.reject("failure message")


# A function which returns a Sinon matcher returning true only if the object
# does not contain the specified key.
keyAbsent = (key) ->
  sinon.match(
    (val) -> key not of val,
    "#{key} was found in object"
  )


describe 'Storage.StorageAdapter', ->
  noop = -> Promise.resolve()
  a = null
  s = null
  sandbox = null

  beforeEach ->
    sandbox = sinon.sandbox.create()
    s = new MockStorage()
    a = new Storage.StorageAdapter(s, noop)

    sandbox.spy(s, 'create')
    sandbox.spy(s, 'update')
    sandbox.spy(s, 'delete')
    sandbox.spy(s, 'query')

  afterEach ->
    sandbox.restore()

  # Helper function for testing that the correct data is received by the store
  # method of the specified name.
  assertDataReceived = (method, passed, expected, done) ->
    a[method](passed)
    .then ->
      sinon.assert.calledOnce(s[method])
      sinon.assert.calledWith(s[method], expected)
    .then(done, done)

  # Helper function for testing that the return value from the adapter is a
  # correctly resolved promise
  assertPromiseResolved = (method, passed, expected, done) ->
    a[method](passed)
    .then (ret) ->
      # The returned object should be the SAME object as originally passed in
      assert.strictEqual(ret, passed)
      # But its contents may have changed
      assert.deepEqual(ret, expected)
    .then(done, done)

  # Helper function for testing that the return value from the adapter is a
  # correctly rejected promise
  assertPromiseRejected = (method, passed, expected, done) ->
    s = new FailingMockStorage()
    a = new Storage.StorageAdapter(s, noop)
    a[method](passed)
    .then(
      -> done(new Error("Promise should not have been resolved!")),
      (ret) ->
        assert.deepEqual(ret, expected)
    )
    .then(done, done)

  describe '#create()', ->

    it "should pass annotation data to the store's #create()", (done) ->
      assertDataReceived(
        'create',
        {some: 'data'},
        sinon.match({some: 'data'}),
        done
      )

    it "should return a promise resolving to the created annotation", (done) ->
      assertPromiseResolved(
        'create',
        {some: 'data'},
        {some: 'data', stored: true},
        done
      )

    it "should return a promise that rejects if the store rejects", (done) ->
      assertPromiseRejected(
        'create',
        {some: 'data'},
        "failure message",
        done
      )

    it "should strip _local data before passing to the store", (done) ->
      assertDataReceived(
        'create',
        {some: 'data', _local: 'nottobepassedon'},
        keyAbsent('_local'),
        done
      )

    it "should run the onBeforeAnnotationCreated/onAnnotationCreated hooks " +
       "before/after calling the store", (done) ->
      hr = new MockHookRunner()
      s = new MockStorage()
      s._callRecorder = hr.runHook
      a = new Storage.StorageAdapter(s, hr.runHook)
      ann = {some: 'data'}
      a.create(ann)
        .then ->
          assert.deepEqual(hr.calls[0].name, 'onBeforeAnnotationCreated')
          assert.strictEqual(hr.calls[0].args[0], ann)
          assert.deepEqual(hr.calls[1].name, 'create')
          assert.deepEqual(hr.calls[2].name, 'onAnnotationCreated')
          assert.strictEqual(hr.calls[2].args[0], ann)
        .then(done, done)

  describe '#update()', ->

    it "should pass annotation data to the store's #update()", (done) ->
      assertDataReceived(
        'update',
        {id: '123', some: 'data'},
        sinon.match({id: '123', some: 'data'}),
        done
      )

    it "should return a promise resolving to the updated annotation", (done) ->
      assertPromiseResolved(
        'update',
        {id: '123', some: 'data'},
        {id: '123', some: 'data', stored: true},
        done
      )

    it "should return a promise that rejects if the store rejects", (done) ->
      assertPromiseRejected(
        'update',
        {id: '123', some: 'data'},
        "failure message",
        done
      )

    it "should strip _local data before passing to the store", (done) ->
      assertDataReceived(
        'update',
        {id: '123', some: 'data', _local: 'nottobepassedon'},
        keyAbsent('_local'),
        done
      )

    it "should throw a TypeError if the data lacks an id", ->
      ann = {some: 'data'}
      assert.throws((-> a.update(ann)), TypeError, ' id ')

    it "should run the onBeforeAnnotationUpdated/onAnnotationUpdated hooks " +
       "before/after calling the store", (done) ->
      hr = new MockHookRunner()
      s = new MockStorage()
      s._callRecorder = hr.runHook
      a = new Storage.StorageAdapter(s, hr.runHook)
      ann = {id: '123', some: 'data'}
      a.update(ann)
        .then ->
          assert.deepEqual(hr.calls[0].name, 'onBeforeAnnotationUpdated')
          assert.strictEqual(hr.calls[0].args[0], ann)
          assert.deepEqual(hr.calls[1].name, 'update')
          assert.deepEqual(hr.calls[2].name, 'onAnnotationUpdated')
          assert.strictEqual(hr.calls[2].args[0], ann)
        .then(done, done)

  describe '#delete()', ->

    it "should pass annotation data to the store's #delete()", (done) ->
      assertDataReceived(
        'delete',
        {id: '123', some: 'data'},
        sinon.match({id: '123', some: 'data'}),
        done
      )

    it "should return a promise resolving to the deleted annotation", (done) ->
      assertPromiseResolved(
        'delete',
        {id: '123', some: 'data'},
        {id: '123', some: 'data', stored: true},
        done
      )

    it "should return a promise that rejects if the store rejects", (done) ->
      assertPromiseRejected(
        'delete',
        {id: '123', some: 'data'},
        "failure message",
        done
      )

    it "should strip _local data before passing to the store", (done) ->
      assertDataReceived(
        'delete',
        {id: '123', some: 'data', _local: 'nottobepassedon'},
        keyAbsent('_local'),
        done
      )

    it "should throw a TypeError if the data lacks an id", ->
      ann = {some: 'data'}
      assert.throws((-> a.delete(ann)), TypeError, ' id ')

    it "should run the onBeforeAnnotationDeleted/onAnnotationDeleted hooks " +
       "before/after calling the store", (done) ->
      hr = new MockHookRunner()
      s = new MockStorage()
      s._callRecorder = hr.runHook
      a = new Storage.StorageAdapter(s, hr.runHook)
      ann = {id: '123', some: 'data'}
      a.delete(ann)
        .then ->
          assert.deepEqual(hr.calls[0].name, 'onBeforeAnnotationDeleted')
          assert.strictEqual(hr.calls[0].args[0], ann)
          assert.deepEqual(hr.calls[1].name, 'delete')
          assert.deepEqual(hr.calls[2].name, 'onAnnotationDeleted')
          assert.strictEqual(hr.calls[2].args[0], ann)
        .then(done, done)

  describe '#query()', ->

    it "should invoke the query method on the registered store service", ->
      query = {url: 'foo'}
      a.query(query)
      sinon.assert.calledWith(s.query, query)

    it "should return a promise resolving to the query result", (done) ->
      query = {url: 'foo'}
      a.query(query)
      .then (ret) ->
        assert.deepEqual(ret, [[], {total: 0}])
      .then(done, done)

    it "should return a promise that rejects if the store rejects", (done) ->
      s = new FailingMockStorage()
      a = new Storage.StorageAdapter(s, noop)
      query = {url: 'foo'}
      res = a.query(query)
      res.then(
        -> done(new Error("Promise should not have been resolved!")),
        (ret) ->
          assert.deepEqual(ret, "failure message")
      )
      .then(done, done)

  describe '#load()', ->

    it "should invoke the query method on the registered store service", ->
      query = {url: 'foo'}
      a.load(query)
      sinon.assert.calledWith(s.query, query)

    it "should run the onAnnotationsLoaded hook after calling " +
       "the store", (done) ->
      hr = new MockHookRunner()
      s = new MockStorage()
      s._callRecorder = hr.runHook
      a = new Storage.StorageAdapter(s, hr.runHook)
      query = {url: 'foo'}
      a.load(query)
        .then ->
          assert.deepEqual(hr.calls[0].name, 'query')
          assert.deepEqual(hr.calls[1].name, 'onAnnotationsLoaded')
          assert.deepEqual(hr.calls[1].args, [[[], {total: 0}]])
        .then(done, done)
