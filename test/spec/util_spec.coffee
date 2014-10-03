h = require('helpers')
Util = require('../../src/util')
$ = Util.$

describe 'Util.flatten()', ->
  it "flattens the contents of an Array", ->
    flattened = Util.flatten([[1,2], 'lorem ipsum', [{}, null, [], undefined]])
    assert.deepEqual(flattened, [1, 2, 'lorem ipsum', {}, null, undefined])

describe 'Util.escape()', ->
  it "should escape any HTML special characters into entities", ->
    assert.equal(Util.escape('<>"&'), '&lt;&gt;&quot;&amp;')

describe 'Util.uuid()', ->
  it "should return a unique id on each call", ->
    counter = 100
    results = []

    while counter--
      current = Util.uuid()
      assert.equal(results.indexOf(current), -1)
      results.push current
