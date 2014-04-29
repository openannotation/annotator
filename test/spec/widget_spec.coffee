$ = require('../../src/util').$
Widget = require('../../src/widget')

class MyWidget extends Widget
  constructor: (@widget) ->
    super

describe "Widget", ->
  element = null
  widget = null

  beforeEach ->
    element = $('<div />')[0]
    widget  = new MyWidget(element)

  describe "constructor", ->
    it "should extend the Widget#classes object with child classes", ->
      class ChildWidget extends MyWidget
        classes:
          customClass: 'my-custom-class'
          anotherClass: 'another-class'

      child = new ChildWidget(element)
      assert.deepEqual(child.classes, {
        hide: 'annotator-hide'
        invert:
          x: 'annotator-invert-x'
          y: 'annotator-invert-y'
        customClass: 'my-custom-class'
        anotherClass: 'another-class'
      })

  describe "invertX", ->
    it "should add the Widget#classes.invert.x class to the Widget#widget", ->
      $(widget.widget).removeClass(widget.classes.invert.x)
      widget.invertX()
      assert.isTrue($(widget.widget).hasClass(widget.classes.invert.x))

  describe "invertY", ->
    it "should add the Widget#classes.invert.y class to the Widget#widget", ->
      $(widget.widget).removeClass(widget.classes.invert.y)
      widget.invertY()
      assert.isTrue($(widget.widget).hasClass(widget.classes.invert.y))

  describe "isInvertedY", ->
    it "should return the vertical inverted status of the Widget", ->
      assert.isFalse(widget.isInvertedY())
      widget.invertY()
      assert.isTrue(widget.isInvertedY())

  describe "isInvertedX", ->
    it "should return the horizontal inverted status of the Widget", ->
      assert.isFalse(widget.isInvertedX())
      widget.invertX()
      assert.isTrue(widget.isInvertedX())

  describe "resetOrientation", ->
    it "should remove the Widget#classes.invert classes from the Widget#widget", ->
      $(widget.widget)
      .addClass(widget.classes.invert.x)
      .addClass(widget.classes.invert.y)

      widget.resetOrientation()
      assert.isFalse($(widget.widget).hasClass(widget.classes.invert.x))
      assert.isFalse($(widget.widget).hasClass(widget.classes.invert.y))

  describe "checkOrientation", ->
    mocks = [
      # Fits in viewport
      {
        window:  { width: 920, scrollTop: 0, scrollLeft: 0 }
        element: { offset: {top: 300, left: 0 }, width: 250 }
      }
      # Hidden to the right
      {
        window:  { width: 920, scrollTop: 0, scrollLeft: 0 }
        element: { offset: {top: 200, left: 900 }, width: 250 }
      }
      # Hidden to the top
      {
        window:  { width: 920, scrollTop: 0, scrollLeft: 0 }
        element: { offset: {top: -100, left: 0 }, width: 250 }
      }
      # Hidden to the top and right
      {
        window:  { width: 920, scrollTop: 0, scrollLeft: 0 }
        element: { offset: {top: -100, left: 900 }, width: 250 }
      }
      # Hidden at the top due to scrolling Y
      {
        window:  { width: 920, scrollTop: 300, scrollLeft: 0 }
        element: { offset: {top: 200, left: 0 }, width: 250 }
      }
      # Visible to the right due to scrolling X
      {
        window:  { width: 750, scrollTop: 0 , scrollLeft: 300 }
        element: { offset: {top: 200, left: 750 }, width: 250 }
      }
    ]

    beforeEach ->
      {window, element} = mocks.shift()

      sinon.stub($.fn, 'init').returns({
        width: sinon.stub().returns(window.width)
        scrollTop: sinon.stub().returns(window.scrollTop)
        scrollLeft: sinon.stub().returns(window.scrollLeft)
        children: sinon.stub().returns({
          offset: sinon.stub().returns(element.offset)
          width:  sinon.stub().returns(element.width)
        })
      })

      sinon.stub(widget, 'invertX')
      sinon.stub(widget, 'invertY')
      sinon.stub(widget, 'resetOrientation')

      widget.checkOrientation()

    afterEach ->
      $.fn.init.restore()

    it "should reset the widget each time", ->
      assert(widget.resetOrientation.calledOnce)
      assert.isFalse(widget.invertX.called)
      assert.isFalse(widget.invertY.called)

    it "should invert the widget if it does not fit horizontally", ->
      assert(widget.invertX.calledOnce)
      assert.isFalse(widget.invertY.called)

    it "should invert the widget if it does not fit vertically", ->
      assert.isFalse(widget.invertX.called)
      assert(widget.invertY.calledOnce)

    it "should invert the widget if it does not fit horizontally or vertically", ->
      assert(widget.invertX.calledOnce)
      assert(widget.invertY.calledOnce)

    it "should invert the widget if it does not fit vertically and the window is scrolled", ->
      assert.isFalse(widget.invertX.called)
      assert(widget.invertY.calledOnce)

    it "should invert the widget if it fits horizontally due to the window scrolled", ->
      assert.isFalse(widget.invertX.called)
      assert.isFalse(widget.invertY.called)
