h = require('helpers')
Adder = require('../../../src/plugin/adder')
Util = require('../../../src/util')
$ = Util.$

describe 'Adder plugin', ->
  elem = null
  core = null
  plugin = null

  beforeEach ->
    h.addFixture('adder')
    elem = h.fix()
    core = {}
    plugin = new Adder(elem)
    plugin.configure({core: core})
    plugin.pluginInit()

  afterEach ->
    plugin.destroy()
    h.clearFixtures()

  it 'should start hidden', ->
    assert.isFalse(plugin.isShown())

  describe '.show()', ->
    it 'should make the adder widget visible', ->
      plugin.show()
      assert.isTrue($(plugin.adder).is(':visible'))

    it 'should use the interactionPoint set on the core object to set its
        position, if available', ->
      core.interactionPoint = {
        top: '100px'
        left: '200px'
      }
      plugin.show()
      assert.deepEqual(
        {
          top: plugin.adder.style.top
          left: plugin.adder.style.left
        },
        core.interactionPoint
      )

  describe '.hide()', ->
    it 'should hide the adder widget', ->
      plugin.show()
      plugin.hide()
      assert.isFalse($(plugin.adder).is(':visible'))

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
      assert.isFalse(document.body in $(plugin.adder).parents())

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
      core.annotations = {create: sinon.stub()}
      sinon.stub(Util, 'mousePosition').returns(mockOffset)
      sinon.stub(Util.getGlobal(), 'getSelection').returns(mockSelection)

    afterEach ->
      Util.mousePosition.restore()
      Util.getGlobal().getSelection.restore()

    it "should show itself if a selection was made (on mouseup)", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      assert.isTrue(plugin.isShown())

    it "should not show itself if the selection was empty (on mouseup)", ->
      mockSelection.removeAllRanges()
      $(Util.getGlobal().document.body).trigger('mouseup')
      assert.isFalse(plugin.isShown())

    it "should not show itself if the current selection is of an Annotator
        element", ->
      # Set the selection to a div which has the 'annotator-adder' class set.
      mockSelection = new h.MockSelection(
        h.fix(),
        ['/div/div/p', 0, '/div/div/p', 1, 'Part of the Annotator UI.', '--']
      )
      Util.getGlobal().getSelection.restore()
      sinon.stub(Util.getGlobal(), 'getSelection').returns(mockSelection)

      $(Util.getGlobal().document.body).trigger('mouseup')
      assert.isFalse(plugin.isShown())

    it "should set the interactionPoint to the mouse position if a selection
        was made (on mouseup)", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      assert.equal(core.interactionPoint, mockOffset)

    it "should create an annotation from the current selection when
        left-clicked", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      $(plugin.adder).find('button').trigger({
        type: 'click',
        which: 1,
      })
      sinon.assert.called(core.annotations.create)
      ann = core.annotations.create.args[0][0]  # first arg from first call
      assert.equal(ann.quote, "Hello world!")
      assert.deepEqual(
        ann.ranges[0].toObject(),
        {
          start: "/div[1]/p[1]",
          startOffset: 0,
          end: "/div[1]/p[1]",
          endOffset: 12,
        }
      )

    it "should not create an annotation from the current selection when
        right-clicked", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      $(plugin.adder).find('button').trigger({
        type: 'click',
        which: 3,
      })
      sinon.assert.notCalled(core.annotations.create)

    it "should hide the adder when left-clicked", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      $(plugin.adder).find('button').trigger({
        type: 'click',
        which: 1,
      })
      assert.isFalse(plugin.isShown())

    it "should ignore annotator-created highlight elements when creating
        annotations", ->
      # Set the selection to a span which has the 'annotator-hl' class set.
      mockSelection = new h.MockSelection(
        h.fix(),
        ['/div/p[2]/span', 0, '/div/p[2]/span', 1,
         'Giraffes like leaves.', '--']
      )
      Util.getGlobal().getSelection.restore()
      sinon.stub(Util.getGlobal(), 'getSelection').returns(mockSelection)

      # Make selection
      $(Util.getGlobal().document.body).trigger('mouseup')
      # Click on adder
      $(plugin.adder).find('button').trigger({
        type: 'click',
        which: 1,
      })
      sinon.assert.called(core.annotations.create)
      ann = core.annotations.create.args[0][0]  # first arg from first call
      assert.equal(ann.quote, "Giraffes like leaves.")
      assert.deepEqual(
        ann.ranges[0].toObject(),
        {
          start: "/div[1]/p[2]",
          startOffset: 0,
          end: "/div[1]/p[2]",
          endOffset: 21,
        }
      )
