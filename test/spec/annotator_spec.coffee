h = require('helpers')

Annotator = require('annotator')
Util = Annotator.Util
Range = Annotator.Range
$ = Util.$


describe 'Annotator', ->
  annotator = null

  beforeEach ->
    annotator = new Annotator($('<div></div>')[0])

  afterEach ->
    annotator.destroy()

  describe "constructor", ->
    beforeEach ->
      sinon.stub(annotator, '_setupDynamicStyle').returns(annotator)

    it 'should include the default modules', ->
      assert.isObject(annotator['annotations'], 'annotations service exists')
      assert.isObject(annotator['annotations'], 'storage service exists')

  describe "#destroy()", ->
    it "should remove Annotator's elements from the page", ->
      annotator.destroy()
      assert.equal(annotator.element.find('[class^=annotator-]').length, 0)

  describe "_setupDynamicStyle", ->
    $fix = null

    beforeEach ->
      h.addFixture 'annotator'
      $fix = $(h.fix())

    afterEach -> h.clearFixtures()

    it 'should ensure Annotator z-indices are larger than others in the page', ->
      $fix.show()

      $adder = $('<div style="position:relative;" class="annotator-adder">&nbsp;</div>').appendTo($fix)
      $filter = $('<div style="position:relative;" class="annotator-filter">&nbsp;</div>').appendTo($fix)

      check = (minimum) ->
        adderZ = parseInt($adder.css('z-index'), 10)
        filterZ = parseInt($filter.css('z-index'), 10)
        assert.isTrue(adderZ > minimum)
        assert.isTrue(filterZ > minimum)
        assert.isTrue(adderZ > filterZ)

      check(1000)

      $fix.append('<div style="position: relative; z-index: 2000"></div>')
      annotator._setupDynamicStyle()
      check(2000)

      $fix.append('<div style="position: relative; z-index: 10000"></div>')
      annotator._setupDynamicStyle()
      check(10000)

      $fix.hide()

  describe "dumpAnnotations", ->
    it "returns false and prints a warning if no Store plugin is active", ->
      sinon.stub(console, 'warn')
      assert.isFalse(annotator.dumpAnnotations())
      assert(console.warn.calledOnce)

    it "returns the results of the Store plugins dumpAnnotations method", ->
      annotator.store = { dumpAnnotations: -> [1,2,3] }
      assert.deepEqual(annotator.dumpAnnotations(), [1,2,3])

  describe "addPlugin", ->
    plugin = null
    Foo = null

    beforeEach ->
      plugin = {
        pluginInit: sinon.spy()
      }
      Foo = sinon.stub().returns(plugin)
      Annotator.Plugin.register('Foo', Foo)

    it "should add and instantiate a plugin of the specified name", ->
      annotator.addPlugin('Foo')
      assert.isTrue(Foo.calledWith(annotator.element[0], undefined))

    it "should pass on the provided options", ->
      options = {foo: 'bar'}
      annotator.addPlugin('Foo', options)
      assert.isTrue(Foo.calledWith(annotator.element[0], options))

    it "should attach the Annotator instance", ->
      annotator.addPlugin('Foo')
      assert.equal(plugin.annotator, annotator)

    it "should call Plugin#pluginInit()", ->
      annotator.addPlugin('Foo')
      assert(plugin.pluginInit.calledOnce)

    it "should complain if you try and instantiate a plugin that doesn't exist", ->
      sinon.stub(console, 'error')
      annotator.addPlugin('Bar')
      assert.isFalse(annotator.plugins['Bar']?)
      assert(console.error.calledOnce)
      console.error.restore()


describe 'Annotator.Factory', ->
  it "should use Annotator as the default core constructor", ->
    factory = new Annotator.Factory()
    a = factory.getInstance()
    assert.instanceOf(a, Annotator)


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

  beforeEach ->
    window._Selection = window.getSelection

  afterEach ->
    window.getSelection = window._Selection

  it "should return true if the browser has window.getSelection method", ->
    window.getSelection = ->
    assert.isTrue(Annotator.supported())

  xit "should return false if the browser has no window.getSelection method", ->
    # The method currently checks for getSelection on load and will always
    # return that result.
    window.getSelection = undefined
    assert.isFalse(Annotator.supported())
