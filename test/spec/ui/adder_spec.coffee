h = require('helpers')

UI = require('../../../src/ui')
Util = require('../../../src/util')

$ = Util.$


class MockStorageAdapter

  constructor: ->
    @calls = []

  create: (ann) ->
    @calls.push(['create', ann])


describe 'UI.Adder', ->
  a = null
  mockRegistry = null

  beforeEach ->
    h.addFixture('adder')
    mockRegistry = {annotations: new MockStorageAdapter()}
    a = new UI.Adder(mockRegistry)

  afterEach ->
    a.destroy()
    h.clearFixtures()

  it 'should start hidden', ->
    assert.isFalse(a.isShown())


  describe '.show()', ->
    it 'should make the adder widget visible', ->
      a.show()
      assert.isTrue(a.element.is(':visible'))


  describe '.hide()', ->
    it 'should hide the adder widget', ->
      a.show()
      a.hide()
      assert.isFalse(a.element.is(':visible'))


  describe '.isShown()', ->
    it 'should return true if the adder is shown', ->
      a.show()
      assert.isTrue(a.isShown())

    it 'should return false if the adder is hidden', ->
      a.hide()
      assert.isFalse(a.isShown())


  describe '.destroy()', ->
    it 'should remove the adder from the document', ->
      a.destroy()
      assert.isFalse(document.body in a.element.parents())


  describe '.onSelection()', ->
    mockOffset = null
    mockRanges = null

    beforeEach ->
      mockOffset = {top: 123, left: 456}
      mockRanges = ['range1', 'range2']

      sinon.stub(Util, 'mousePosition').returns(mockOffset)

    afterEach ->
      Util.mousePosition.restore()

    it "should show itself on selection events with valid data", ->
      a.onSelection(mockRanges, null)
      assert.isTrue(a.isShown())

    it "should hide itself on empty selection events", ->
      a.show()
      a.onSelection([], null)
      assert.isFalse(a.isShown())

    it "should use the event mouse position to position itself", ->
      a.onSelection(mockRanges, null)
      assert.equal(a.element.css('top'), '123px')
      assert.equal(a.element.css('left'), '456px')

    it "should create an annotation when the button is left-clicked", ->
      a.onSelection(mockRanges, null)
      a.element.find('button').trigger({
        type: 'click',
        which: 1,
      })
      assert.deepEqual(
        mockRegistry.annotations.calls,
        [['create', {ranges: mockRanges}]]
      )

    it "should not create an annotation when the button is right-clicked", ->
      a.onSelection(mockRanges, null)
      a.element.find('button').trigger({
        type: 'click',
        which: 3,
      })
      assert.deepEqual(mockRegistry.annotations.calls, [])

    it "should hide the adder when the button is left-clicked", ->
      $(Util.getGlobal().document.body).trigger('mouseup')
      a.element.find('button').trigger({
        type: 'click',
        which: 1,
      })
      assert.isFalse(a.isShown())
