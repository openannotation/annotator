BackboneEvents = require('backbone-events-standalone')
h = require('helpers')
TextSelector = require('../../../src/plugin/textselector')
Range = require('../../../src/range')
Util = require('../../../src/util')
$ = Util.$

describe 'Text Selector plugin', ->
  elem = null
  core = null
  plugin = null

  beforeEach ->
    h.addFixture('adder')
    elem = h.fix()
    core = {
      annotations: {
        create: sinon.spy()
      }
    }
    BackboneEvents.mixin(core)
    plugin = new TextSelector(elem)
    plugin.configure({core: core})
    plugin.pluginInit()

  afterEach ->
    plugin.destroy()
    h.clearFixtures()

  describe '.captureDocumentSelection()', ->

    beforeEach ->
      mockSelection = new h.MockSelection(
        h.fix(),
        ['/div/p', 0, '/div/p', 1, 'Hello world!', '--']
      )
      sinon.stub(Util.getGlobal(), 'getSelection').returns(mockSelection)

    afterEach ->
      Util.getGlobal().getSelection.restore()

    it "should capture and normalise the current document selections", ->
      ranges = plugin.captureDocumentSelection()
      assert.equal(ranges.length, 1)
      assert.equal(ranges[0].text(), 'Hello world!')
      assert.equal(ranges[0].normalize(), ranges[0])


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

    it "should trigger a rawSelection event if a selection was made (on mouseup), and event should have the right type, and should carry the list of normalized ranges", (done) ->
      # Prepare to receive the event  
      core.on('rawSelection', (raw) ->
        try
          assert.equal(raw.type, "text ranges")
          assert.equal(raw.ranges[0].normalize(), raw.ranges[0])
          assert.equal(raw.ranges[0].text(), "Hello world!")
          done()
        catch ex
          done(ex)
      )
      # Trigger the event
      $(Util.getGlobal().document.body).trigger('mouseup')

    it "should trigger an empty selection event if the selection was empty (on mouseup)", (done) ->
      mockSelection.removeAllRanges()        
      # Preppare to receive the event        
      core.on('selection', (annotationSkeleton) ->
        try
          assert.equal(annotationSkeleton, null)
          done()
        catch ex
          done(ex)
      )        
      # Trigger the event
      $(Util.getGlobal().document.body).trigger('mouseup')

    it "should trigger an empty selection event if the current selection is of an Annotator
        element", (done) ->
      # Set the selection to a div which has the 'annotator-adder' class set.
      mockSelection = new h.MockSelection(
        h.fix(),
        ['/div/div/p', 0, '/div/div/p', 1, 'Part of the Annotator UI.', '--']
      )
      Util.getGlobal().getSelection.restore()
      sinon.stub(Util.getGlobal(), 'getSelection').returns(mockSelection)
      # Preppare to receive the event
      core.on('selection', (annotationSkeleton) ->
        try
          assert.equal(annotationSkeleton, null)
          done()
        catch ex
          done(ex)
      )
      # Trigger the event
      $(Util.getGlobal().document.body).trigger('mouseup')

    it "should set the interactionPoint to the mouse position if a selection
        was made (on mouseup)", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      assert.equal(core.interactionPoint, mockOffset)

