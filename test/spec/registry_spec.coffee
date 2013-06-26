class MockStore
  create: (data) ->
    if data.i?
      data.i *= 10
    dfd = new $.Deferred()
    dfd.resolve($.extend({id: 123}, data))
    return dfd.promise()

  update: (data) ->
    if data.i?
      data.i *= 10
    dfd = new $.Deferred()
    dfd.resolve($.extend({}, data))
    return dfd.promise()

  delete: (data) ->
    dfd = new $.Deferred()
    if data.i?
      dfd.resolve(data.i * 10)
    else
      dfd.resolve()
    return dfd.promise()

  query: (data) ->
    dfd = new $.Deferred()
    dfd.resolve([{id: 1}, {id: 2}], {total:2})
    return dfd.promise()

describe 'Annotator.Registry', ->
  m = null
  r = null

  beforeEach ->
    m = new MockStore()
    r = new Annotator.Registry(m)

  it 'should take a Store plugin as its first constructor argument', ->
    assert.equal(r.store, m)

  describe '#create()', ->

    it "should pass annotation data to the store's #create()", ->
      sinon.spy(m, 'create')

      r.create({some: 'data'})
      assert(m.create.calledOnce, 'store .create() called once')
      assert(
        m.create.calledWith({some: 'data'}),
        'store .create() called with correct args'
      )

      m.create.reset()

    it "should return a promise resolving to the created annotation", (done) ->
      r.create({some: 'data'})
        .done (a) ->
          assert.deepEqual(a, {id: 123, some: 'data'})
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))


    it "should publish beforeAnnotationCreated before passing to the store", (done) ->
      r.subscribe('beforeAnnotationCreated', (ann) -> ann.i += 1)
      r.create({i: 1})
        .done (a) ->
          assert.deepEqual(a, {id: 123, i: 20})
          done()

    it "should publish annotationCreated once the store promise resolves", (done) ->
      r.subscribe('annotationCreated', (ann) ->
        assert.deepEqual(ann, {id: 123, i: 10})
        done()
      )
      r.create({i: 1})
        .done((a) -> a.i += 1)

    it "should strip an annotation of any _localData before passing to the store", ->
      sinon.spy(m, 'create')
      ld = {foo: 'bar', numbers: [1,2,3]}
      r.create({some: 'data', _localData: ld})
      assert(
        m.create.calledWith({some: 'data'})
        'annotation _localData stripped before store .create() call'
      )

  describe '#update()', ->

    it "should return a rejected promise if the data lacks an id", (done) ->
      r.update({some: 'data'})
        .done ->
          done(new Error("promise unexpectedly resolved"))
        .fail (ann, msg) ->
          assert.deepEqual(ann, {some: 'data'})
          assert.include(msg, ' id ')
          done()

    it "should pass annotation data to the store's #update()", ->
      sinon.spy(m, 'update')

      r.update({id: 123, some: 'data'})
      assert(m.update.calledOnce, 'store .update() called once')
      assert(
        m.update.calledWith({id: 123, some: 'data'}),
        'store .update() called with correct args'
      )

      m.update.reset()

    it "should return a promise resolving to the updated annotation", (done) ->
      r.update({id:123, some: 'data'})
        .done (r) ->
          assert.deepEqual(r, {id: 123, some: 'data'})
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

    it "should publish beforeAnnotationUpdated before passing to the store", (done) ->
      r.subscribe('beforeAnnotationUpdated', (ann) -> ann.i += 1)
      r.update({id:123, i: 1})
        .done (a) ->
          assert.deepEqual(a, {id: 123, i: 20})
          done()

    it "should publish annotationUpdated once the store promise resolves", (done) ->
      r.subscribe('annotationUpdated', (ann) ->
        assert.deepEqual(ann, {id: 123, i: 10})
        done()
      )
      r.update({id: 123, i: 1})
        .done((a) -> a.i += 1)

    it "should strip an annotation of any _localData before passing to the store", ->
      sinon.spy(m, 'update')
      ld = {foo: 'bar', numbers: [1,2,3]}
      r.update({id: 123, some: 'data', _localData: ld})
      assert(
        m.update.calledWith({id: 123, some: 'data'})
        'annotation _localData stripped before store .update() call'
      )

  describe '#delete()', ->

    it "should return a rejected promise if the data lacks an id", (done) ->
      r.delete({some: 'data'})
        .done ->
          done(new Error("promise unexpectedly resolved"))
        .fail (ann, msg) ->
          assert.deepEqual(ann, {some: 'data'})
          assert.include(msg, ' id ')
          done()

    it "should pass annotation data to the store's #delete()", ->
      sinon.spy(m, 'delete')

      r.delete({id: 123, some: 'data'})
      assert(m.delete.calledOnce, 'store .delete() called once')
      assert(
        m.delete.calledWith({id: 123, some: 'data'}),
        'store .delete() called with correct args'
      )

      m.delete.reset()

    it "should return a promise resolving to the resolve value of the store call", (done) ->
      r.delete({id:123, i: 456, some: 'data'})
        .done (ret) ->
          assert.equal(ret, 4560)
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

    it "should publish beforeAnnotationDeleted before passing to the store", (done) ->
      r.subscribe('beforeAnnotationDeleted', (ann) -> ann.i += 1)
      r.delete({id:123, i: 1})
        .done (a) ->
          assert.equal(a, 20)
          done()

    it "should publish annotationDeleted once the store promise resolves", (done) ->
      r.subscribe('annotationDeleted', (ann) ->
        assert.equal(ann, 10)
        done()
      )
      r.delete({id: 123, i: 1})

    it "should strip an annotation of any _localData before passing to the store", ->
      sinon.spy(m, 'delete')
      ld = {foo: 'bar', numbers: [1,2,3]}
      r.delete({id: 123, some: 'data', _localData: ld})
      assert(
        m.delete.calledWith({id: 123, some: 'data'})
        'annotation _localData stripped before store .delete() call'
      )

  describe '#query()', ->

    it "should pass query data to the store's #query()", ->
      sinon.spy(m, 'query')

      r.query({foo: 'bar', type: 'giraffe'})
      assert(m.query.calledOnce, 'store .query() called once')
      assert(
        m.query.calledWith({foo: 'bar', type: 'giraffe'}),
        'store .query() called with correct args'
      )

      m.query.reset()

    it "should return a promise", (done) ->
      r.query({foo: 'bar', type: 'giraffe'})
        .done () ->
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

  describe '#load()', ->

    it "should pass query data to the store's #query()", ->
      sinon.spy(m, 'query')

      r.load({foo: 'bar', type: 'giraffe'})
      assert(m.query.calledOnce, 'store .query() called once')
      assert(
        m.query.calledWith({foo: 'bar', type: 'giraffe'}),
        'store .query() called with correct args'
      )

      m.query.reset()

    it "should return a promise", (done) ->
      r.load({foo: 'bar', type: 'giraffe'})
        .done () ->
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))
