NullStore = require('../../src/nullstore')

describe 'NullStore', ->
  s = null
  ann = null

  beforeEach ->
    s = new NullStore()
    ann = {id: 123, some: 'data'}

  describe '#create()', ->

    it "should return a promise resolving to the created annotation", (done) ->
      s.create(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

  describe '#update()', ->

    it "should return a promise resolving to the updated annotation", (done) ->
      s.update(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

  describe '#delete()', ->

    it "should return a promise resolving to the deleted annotation object", (done) ->
      ann = {id: 123, some: 'data'}
      s.delete(ann)
        .done (ret) ->
          assert.equal(ret, ann)
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))

  describe '#query()', ->

    it "should return a promise resolving to the results and metadata", (done) ->
      s.query({foo: 'bar', type: 'giraffe'})
        .done (res, meta) ->
          assert.isArray(res)
          assert.isObject(meta)
          done()
        .fail (obj, msg) ->
          done(new Error("promise rejected: #{msg}"))
