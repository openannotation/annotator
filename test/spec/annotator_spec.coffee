Annotator = require('annotator')


describe "Annotator.noConflict()", ->
  _Annotator = null

  beforeEach ->
    _Annotator = Annotator

  afterEach ->
    window.Annotator = _Annotator

  it "should restore the value previously occupied by window.Annotator", ->
    Annotator.noConflict()
    assert.isUndefined(window.Annotator)

  it "should return the Annotator object", ->
    result = Annotator.noConflict()
    assert.equal(result, _Annotator)


describe "Annotator.supported()", ->
  scope = null

  beforeEach ->
    scope = {
      getSelection: ->
      JSON: JSON
    }

  it "returns true if all is well", ->
    assert.isTrue(Annotator.supported(null, scope))

  it "returns false if scope has no getSelection function", ->
    delete scope.getSelection
    assert.isFalse(Annotator.supported(null, scope))

  it "returns false if scope has no JSON object", ->
    delete scope.JSON
    assert.isFalse(Annotator.supported(null, scope))

  it "returns false if scope JSON object has no stringify function", ->
    scope.JSON = {
      parse: ->
    }
    assert.isFalse(Annotator.supported(null, scope))

  it "returns false if scope JSON object has no parse function", ->
    scope.JSON = {
      stringify: ->
    }
    assert.isFalse(Annotator.supported(null, scope))

  it "returns extra details if details is true and all is well", ->
    res = Annotator.supported(true, scope)
    assert.isTrue(res.supported)
    assert.deepEqual(res.errors, [])

  it "returns extra details if details is true and everything is broken", ->
    res = Annotator.supported(true, {})
    assert.isFalse(res.supported)
    assert.equal(res.errors.length, 2)
