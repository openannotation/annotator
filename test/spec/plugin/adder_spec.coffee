h = require('helpers')
Annotator = require('annotator')
Delegator = require('../../../src/delegator')
Adder = require('../../../src/plugin/adder')
Range = require('xpath-range').Range
Util = require('../../../src/util')
$ = Util.$

describe 'Adder plugin', ->
  core = null
  plugin = null

  beforeEach ->
    h.addFixture('adder')
    core = new Delegator(el: h.fix())
    core.annotations = create: sinon.spy()
    plugin = new Adder()
    plugin.core = core
    core.editor = plugin
    plugin.pluginInit()

  afterEach ->
    plugin.destroy()
    h.clearFixtures()

  it 'should start hidden', ->
    assert.isFalse(plugin.isShown())


  describe '.show()', ->
    it 'should make the adder widget visible', ->
      plugin.show()
      assert.isTrue(plugin.element.is(':visible'))

    it 'should use the interactionPoint set on the core object to set its
        position, if available', ->
      core.interactionPoint = {
        top: '100px'
        left: '200px'
      }
      plugin.show()
      assert.deepEqual(
        {
          top: plugin.element[0].style.top
          left: plugin.element[0].style.left
        },
        core.interactionPoint
      )


  describe '.hide()', ->
    it 'should hide the adder widget', ->
      plugin.show()
      plugin.hide()
      assert.isFalse(plugin.element.is(':visible'))


  describe '.isShown()', ->
    it 'should return true if the adder is shown', ->
      plugin.show()
      assert.isTrue(plugin.isShown())

    it 'should return false if the adder is hidden', ->
      plugin.hide()
      assert.isFalse(plugin.isShown())


  describe '.destroy()', ->
    it 'should remove the adder from the document', ->
      plugin.destroy()
      assert.isFalse(document.body in plugin.element.parents())


  describe 'event listeners', ->
    mockOffset = null
    mockRanges = null
    mockSelection = null

    beforeEach ->
      mockOffset = {top: 123, left: 456}
      mockSelection = new h.MockSelection(
        h.fix(),
        ['/div/p', 0, '/div/p', 1, 'Hello world!', '--']
      )
      sinon.stub(Util, 'mousePosition').returns(mockOffset)
      sinon.stub(Util.getGlobal(), 'getSelection').returns(mockSelection)

    afterEach ->
      Util.mousePosition.restore()
      Util.getGlobal().getSelection.restore()

    it "should show itself on selection events with valid data", ->
      core.trigger("selection", "magic");
      assert.isTrue(plugin.isShown())

    it "should hide itself on empty selection events", ->
      plugin.show()
      core.trigger("selection");
      assert.isFalse(plugin.isShown())

    it "should create an annotation from the skeleton received in the selection event when
        left-clicked", ->
      skeleton =
        magic: "data"
      core.trigger('selection', skeleton)
      plugin.element.find('button').trigger({
        type: 'click',
        which: 1,
      })
      sinon.assert.called(core.annotations.create)
      ann = core.annotations.create.args[0][0]  # first arg from first call
      # Was the annotation really created from the skeleton we passed?
      assert.equal(ann, skeleton)

    it "should not create an annotation from the current selection when
        right-clicked", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      plugin.element.find('button').trigger({
        type: 'click',
        which: 3,
      })
      sinon.assert.notCalled(core.annotations.create)

    it "should hide the adder when left-clicked", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      plugin.element.find('button').trigger({
        type: 'click',
        which: 1,
      })
      assert.isFalse(plugin.isShown())
