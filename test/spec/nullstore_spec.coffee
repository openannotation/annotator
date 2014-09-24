NullStore = require('../../src/nullstore').NullStore

describe 'NullStore', ->
  s = null
  ann = null

  beforeEach ->
    s = NullStore()
    ann = {id: 123, some: 'data'}

  it "#create() should return the created annotation", ->
    res = s.create(ann)
    assert.deepEqual(res, ann)

  it "#create() should assign a locally unique id to created annotations", ->
    res1 = s.create({some: 'data'})
    assert.property(res1, 'id')
    res2 = s.create({some: 'data'})
    assert.property(res2, 'id')
    assert.notEqual(res1.id, res2.id)

  it "#update() should return the updated annotation", ->
    res = s.update(ann)
    assert.deepEqual(res, ann)

  it "#delete() should return the deleted annotation", ->
    res = s.delete(ann)
    assert.deepEqual(res, ann)

  it "#query() should return empty query results", ->
    res = s.query({foo: 'bar', type: 'giraffe'})
    assert.deepEqual(res, {results: []})
