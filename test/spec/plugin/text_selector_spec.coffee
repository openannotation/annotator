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

  describe '.createSkeleton(ranges)', ->
    range1 = null
    range2 = null

    beforeEach ->
      range1 = {
        text: -> '  Hello world!   '
        serialize: -> {serialised: "range1"}
      }
      range2 = {
        text: -> 'Giraffes wearing sunglasses'
        serialize: -> {serialised: "range2"}
      }

    it "should return an annotation with a quote field, containing the quoted
        text, stripped of leading and trailing whitespace", ->
      annotation = plugin.createSkeleton([range1])
      assert.equal(annotation.quote, 'Hello world!')

    it 'should join the quotes of multiple ranges with " / "', ->
      annotation = plugin.createSkeleton([range1, range2])
      assert.equal(
        annotation.quote,
        'Hello world! / Giraffes wearing sunglasses'
      )

    it "should return an annotation with a ranges field, containing an array
        of serialized ranges", ->
      annotation = plugin.createSkeleton([range1, range2])
      assert.deepEqual(annotation.ranges, [
        {serialised: "range1"},
        {serialised: "range2"},
      ])


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

    it "should trigger a successfulSelection event if a selection was made (on mouseup), and event should carry a proper skeleton", (done) ->
      # Prepare to receive the event  
      core.on('successfulSelection', (ann) ->
        try
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
          done()
        catch ex
          done(ex)
      )
      # Trigger the event
      $(Util.getGlobal().document.body).trigger('mouseup')

    it "should trigger a failedSelection event if the selection was empty (on mouseup)", (done) ->
      mockSelection.removeAllRanges()        
      # Preppare to receive the event        
      core.on('failedSelection', (annotationSkeleton) ->
        try
          done()
        catch ex
          done(ex)
      )        
      # Trigger the event
      $(Util.getGlobal().document.body).trigger('mouseup')

    it "should trigger a failedSelection event if the current selection is of an Annotator
        element", (done) ->
      # Set the selection to a div which has the 'annotator-adder' class set.
      mockSelection = new h.MockSelection(
        h.fix(),
        ['/div/div/p', 0, '/div/div/p', 1, 'Part of the Annotator UI.', '--']
      )
      Util.getGlobal().getSelection.restore()
      sinon.stub(Util.getGlobal(), 'getSelection').returns(mockSelection)
      # Preppare to receive the event
      core.on('failedSelection', (annotationSkeleton) ->
        try
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

    it "should ignore annotator-created highlight elements when creating
        annotations", (done) ->
      # Set the selection to a span which has the 'annotator-hl' class set.
      mockSelection = new h.MockSelection(
        h.fix(),
        ['/div/p[2]/span', 0, '/div/p[2]/span', 1,
         'Giraffes like leaves.', '--']
      )
      Util.getGlobal().getSelection.restore()
      sinon.stub(Util.getGlobal(), 'getSelection').returns(mockSelection)

      # Prepare to receive the event  
      core.on('successfulSelection', (ann) ->
        try
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
          done()        
        catch ex
          done(ex)
      )
      # Make selection to trigger the event
      $(Util.getGlobal().document.body).trigger('mouseup')
