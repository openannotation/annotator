h = require('helpers')

UI = require('../../../src/ui')
Util = require('../../../src/util')

$ = Util.$


describe 'UI.TextSelector', ->
  elem = null
  core = null
  ts = null
  selections = null

  # Helper function to capture selections
  onSelection = (ranges, event) ->
    selections.push({ranges: ranges, event: event})

  beforeEach ->
    h.addFixture('adder')
    elem = h.fix()
    selections = []
    ts = new UI.TextSelector(elem, {
      onSelection: onSelection
    })

  afterEach ->
    ts.destroy()
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
      ranges = ts.captureDocumentSelection()
      assert.equal(ranges.length, 1)
      assert.equal(ranges[0].text(), 'Hello world!')
      assert.equal(ranges[0].normalize(), ranges[0])

  describe 'onSelection event handler', ->
    mockOffset = null
    mockSelection = null
    selections = null

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

    it "should receive the selected ranges when a selection is made", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      assert.equal(selections.length, 1)
      s = selections[0]
      assert.equal(s.ranges[0].text(), 'Hello world!')

    it "should receive the triggering event object when a selection is made", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      assert.equal(selections.length, 1)
      s = selections[0]
      assert.equal(s.event.type, 'mouseup')

    it "should be called with empty ranges if an empty selection is made", ->
      mockSelection.removeAllRanges()
      $(Util.getGlobal().document.body).trigger('mouseup')
      assert.equal(selections.length, 1)
      assert.deepEqual(selections[0].ranges, [])

    it "should be called with empty ranges if the selection is of an Annotator
        element", ->
      # Set the selection to a div which has the 'annotator-adder' class set.
      Util.getGlobal().getSelection.restore()
      mockSelection = new h.MockSelection(
        h.fix(),
        ['/div/div/p', 0, '/div/div/p', 1, 'Part of the Annotator UI.', '--']
      )
      sinon.stub(Util.getGlobal(), 'getSelection').returns(mockSelection)
      $(Util.getGlobal().document.body).trigger('mouseup')
      assert.equal(selections.length, 1)
      assert.deepEqual(selections[0].ranges, [])
