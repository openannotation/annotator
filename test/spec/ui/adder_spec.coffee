h = require('helpers')

UI = require('../../../src/ui')
Util = require('../../../src/util')

$ = Util.$


describe 'UI.Adder', ->
  a = null
  onCreate = null

  beforeEach ->
    h.addFixture('adder')
    onCreate = sinon.stub()

    a = new UI.Adder({
      onCreate: onCreate
    })

  afterEach ->
    a.destroy()
    h.clearFixtures()

  it 'should start hidden', ->
    assert.isFalse(a.isShown())


  describe '.show()', ->
    it 'should make the adder widget visible', ->
      a.show()
      assert.isTrue(a.element.is(':visible'))

    it 'sets the widget position if a position is provided', ->
      position = {
        top: '100px'
        left: '200px'
      }
      a.show(position)
      assert.deepEqual(
        {
          top: a.element[0].style.top
          left: a.element[0].style.left
        },
        position
      )

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


  describe '.load()', ->
    ann = null

    beforeEach ->
      ann = {text: 'foo'}

    it "shows the widget", ->
      a.load(ann)
      assert.isTrue(a.isShown())

    it "sets the widget position if a position is provided", ->
      position = {top: '123px', left: '456px'}
      a.load(ann, position)
      assert.deepEqual(
        {
          top: a.element[0].style.top
          left: a.element[0].style.left
        },
        position
      )

    it "calls the onCreate handler when the button is left-clicked", ->
      a.load(ann)
      a.element.find('button').trigger({
        type: 'click',
        which: 1,
      })
      sinon.assert.calledWith(onCreate, ann)

    it "does not call the onCreate handler when the button is right-clicked", ->
      a.load(ann)
      a.element.find('button').trigger({
        type: 'click',
        which: 3,
      })
      sinon.assert.notCalled(onCreate)

    it "hides the adder when the button is left-clicked", ->
      a.load(ann)
      $(Util.getGlobal().document.body).trigger('mouseup')
      a.element.find('button').trigger({
        type: 'click',
        which: 1,
      })
      assert.isFalse(a.isShown())
