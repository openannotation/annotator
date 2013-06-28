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
    if data.i?
      data.i *= 10
    dfd = new $.Deferred()
    dfd.resolve({})
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
      ann = {some: 'data'}
      r.create(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          assert.deepEqual(ret, {id: 123, some: 'data'})
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))


    it "should publish beforeAnnotationCreated before passing to the store", (done) ->
      ann = {i: 1}
      r.subscribe('beforeAnnotationCreated', (a) -> a.i += 1)
      r.create(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          assert.deepEqual(ret, {id: 123, i: 20})
          done()

    it "should publish annotationCreated once the store promise resolves", (done) ->
      ann = {i: 1}
      r.subscribe('annotationCreated', (ret) ->
        assert.equal(ret, ann)
        assert.deepEqual(ret, {id: 123, i: 10})
        done()
      )
      r.create(ann)
        .done((a) -> a.i += 1)

    it "should strip an annotation of any _local before passing to the store", ->
      sinon.spy(m, 'create')
      local = {foo: 'bar', numbers: [1,2,3]}
      ann = {some: 'data', _local: local}
      r.create(ann)
      assert(
        m.create.calledWith({some: 'data'})
        'annotation _local stripped before store .create() call'
      )

    it "should leave _local in place when firing beforeAnnotationCreated", (done) ->
      local = {foo: 'bar', numbers: [1,2,3]}
      ann = {some: 'data', _local: local}
      obj = null
      r.subscribe('beforeAnnotationCreated', (a) -> obj = JSON.stringify(a))
      r.create(ann)
        .done ->
          assert.deepEqual(JSON.parse(obj), {some: 'data', _local: local})
          done()

    it "should reattach _local before firing annotationCreated", (done) ->
      local = {foo: 'bar', numbers: [1,2,3]}
      ann = {some: 'data', _local: local}
      obj = null
      r.subscribe('annotationCreated', (ann) -> obj = JSON.stringify(ann))
      r.create(ann)
        .done ->
          assert.deepEqual(JSON.parse(obj), {id: 123, some: 'data', _local: local})
          done()

  describe '#update()', ->

    it "should return a rejected promise if the data lacks an id", (done) ->
      ann = {some: 'data'}
      r.update(ann)
        .done ->
          done(new Error("promise unexpectedly resolved"))
        .fail (ret, msg) ->
          assert.equal(ret, ann)
          assert.deepEqual(ret, {some: 'data'})
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

    it "should return a promise resolving to the updated annotation", (done) ->
      ann = {id: 123, some: 'data'}
      r.update(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          assert.deepEqual(ret, {id: 123, some: 'data'})
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

    it "should publish beforeAnnotationUpdated before passing to the store", (done) ->
      ann = {id: 123, i: 1}
      r.subscribe('beforeAnnotationUpdated', (a) -> a.i += 1)
      r.update(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          assert.deepEqual(ret, {id: 123, i: 20})
          done()

    it "should publish annotationUpdated once the store promise resolves", (done) ->
      ann = {id: 123, i: 1}
      r.subscribe('annotationUpdated', (ret) ->
        assert.equal(ret, ann)
        assert.deepEqual(ret, {id: 123, i: 10})
        done()
      )
      r.update(ann)
        .done((a) -> a.i += 1)

    it "should strip an annotation of any _local before passing to the store", ->
      sinon.spy(m, 'update')
      local = {foo: 'bar', numbers: [1,2,3]}
      ann = {id: 123, some: 'data', _local: local}

      r.update(ann)

      assert(
        m.update.calledWith({id: 123, some: 'data'})
        'annotation _local stripped before store .update() call'
      )

    it "should leave _local in place when firing beforeAnnotationUpdated", (done) ->
      local = {foo: 'bar', numbers: [1,2,3]}
      ann = {id: 123, some: 'data', _local: local}
      cache = null
      r.subscribe('beforeAnnotationUpdated', (a) -> cache = JSON.stringify(a))
      r.update(ann)
        .done ->
          assert.deepEqual(JSON.parse(cache), {id: 123, some: 'data', _local: local})
          done()

    it "should reattach _local before firing annotationUpdated", (done) ->
      local = {foo: 'bar', numbers: [1,2,3]}
      ann = {id: 123, some: 'data', _local: local}
      cache = null
      r.subscribe('annotationUpdated', (a) -> cache = JSON.stringify(a))
      r.update(ann)
        .done ->
          assert.deepEqual(JSON.parse(cache), {id: 123, some: 'data', _local: local})
          done()

  describe '#delete()', ->

    it "should return a rejected promise if the data lacks an id", (done) ->
      ann = {some: 'data'}
      r.delete(ann)
        .done ->
          done(new Error("promise unexpectedly resolved"))
        .fail (ret, msg) ->
          assert.equal(ret, ann)
          assert.deepEqual(ret, {some: 'data'})
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

    it "should return a promise resolving to the deleted annotation object", (done) ->
      ann = {id: 123, some: 'data'}
      r.delete(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          assert.deepEqual(ret, {})
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

    it "should publish beforeAnnotationDeleted before passing to the store", (done) ->
      ann = {id: 123, some: 'data'}
      cache = null
      r.subscribe('beforeAnnotationDeleted', (a) -> cache = JSON.stringify(a))
      r.delete(ann)
        .done ->
          assert.deepEqual(JSON.parse(cache), {id: 123, some: 'data'})
          done()

    it "should publish annotationDeleted once the store promise resolves", (done) ->
      ann = {id: 123, some: 'data'}
      r.subscribe('annotationDeleted', (ret) ->
        assert.equal(ret, ann)
        assert.deepEqual(ret, {})
        done()
      )
      r.delete(ann)

    it "should strip an annotation of any _local before passing to the store", ->
      sinon.spy(m, 'delete')
      local = {foo: 'bar', numbers: [1,2,3]}
      r.delete({id: 123, some: 'data', _local: local})
      assert(
        m.delete.calledWith({id: 123, some: 'data'})
        'annotation _local stripped before store .delete() call'
      )

    it "should leave _local in place when firing beforeAnnotationDeleted", (done) ->
      local = {foo: 'bar', numbers: [1,2,3]}
      ann = {id: 123, some: 'data', _local: local}
      cache = null
      r.subscribe('beforeAnnotationDeleted', (a) -> cache = JSON.stringify(a))
      r.delete(ann)
        .done ->
          assert.deepEqual(JSON.parse(cache), {id: 123, some: 'data', _local: local})
          done()

    it "should reattach _local before firing annotationDeleted", (done) ->
      local = {foo: 'bar', numbers: [1,2,3]}
      ann = {id: 123, some: 'data', _local: local}
      cache = null
      r.subscribe('annotationDeleted', (a) -> cache = JSON.stringify(a))
      r.delete(ann)
        .done ->
          assert.deepEqual(JSON.parse(cache), {_local: local})
          done()

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
