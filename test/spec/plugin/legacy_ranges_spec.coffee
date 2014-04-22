BackboneEvents = require('backbone-events-standalone')
h = require('helpers')
LegacyRanges = require('../../../src/plugin/legacyranges')
Range = require('../../../src/range')
Util = require('../../../src/util')
$ = Util.$

describe 'Legacy Ranges plugin', ->
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
    plugin = new LegacyRanges(elem)
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


  describe 'event listeners', ->
    mockOffset = null
    mockRanges = null
    mockSelection = null
    range1 = null
    range2 = null

    beforeEach ->
      mockOffset = {top: 123, left: 456}
      mockSelection = new h.MockSelection(
        h.fix(),
        ['/div/p', 0, '/div/p', 1, 'Hello world!', '--']
      )
      range1 = {
        text: -> '  Hello world!   '
        serialize: -> {serialised: "range1"}
      }
      range2 = {
        text: -> 'Giraffes wearing sunglasses'
        serialize: -> {serialised: "range2"}
      }
      sinon.stub(Util, 'mousePosition').returns(mockOffset)
      sinon.stub(Util.getGlobal(), 'getSelection').returns(mockSelection)

    afterEach ->
      Util.mousePosition.restore()
      Util.getGlobal().getSelection.restore()

    it "should trigger a selection event on a rawSelection event, and new event should carry a proper skeleton, built by serializing the ranges from the old event", (done) ->
      # Prepare to receive the event
      core.on('selection', (ann) ->
        try
          assert.equal(ann.quote, "Hello world! / Giraffes wearing sunglasses")
          assert.equal(ann.ranges.length, 2)
          assert.deepEqual(
            ann.ranges[0], { serialised: "range1" }
            ann.ranges[1], { serialised: "range2" }
          )
          done()
        catch ex
          done(ex)
      )

      # Prepare a raw selection
      raw =
        type: "text ranges"
        ranges: [range1, range2]
      # Trigger the event
      core.trigger "rawSelection", raw

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

      # Get a normalized range from the selection
      # (As TextSelector would do)
      browserRange = new Range.BrowserRange mockSelection.ranges[0]
      normedRange = browserRange.normalize().limit(elem)

      # Check if the selection is indeed inside a SPAN
      assert.equal("SPAN", normedRange.commonAncestor.tagName)

      # Prepare to receive the event
      core.on('selection', (ann) ->
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

      # Prepare a raw selection
      raw =
        type: "text ranges"
        ranges: [normedRange]
      # Inject the input event to trigger the output event
      core.trigger "rawSelection", raw
