describe "Annotator.Widget", ->
  widget = null
  
  beforeEach ->
    element = $('<div />')[0]
    widget  = new Annotator.Widget(element)
  
  describe "constructor", ->
    it "should extend the Widget#classes object with child classes", ->
      class ChildWidget extends Annotator.Widget
        classes:
          customClass: 'my-custom-class'
          anotherClass: 'another-class'
      
      child = new ChildWidget()
      expect(child.classes).toEqual({
        hide: 'annotator-hide'
        invert:
          x: 'annotator-invert-x'
          y: 'annotator-invert-y'
        customClass: 'my-custom-class'
        anotherClass: 'another-class'
      })

  describe "invertX", ->
    it "should add the Widget#classes.invert.x class to the Widget#element", ->
      widget.element.removeClass(widget.classes.invert.x);
      widget.invertX()
      expect(widget.element.hasClass(widget.classes.invert.x)).toBe(true)

  describe "invertX", ->
    it "should add the Widget#classes.invert.y class to the Widget#element", ->
      widget.element.removeClass(widget.classes.invert.y);
      widget.invertY()
      expect(widget.element.hasClass(widget.classes.invert.y)).toBe(true)

  describe "resetX", ->
    it "should remove the Widget#classes.invert.x class from the Widget#element", ->
      widget.element.addClass(widget.classes.invert.x);
      widget.resetX()
      expect(widget.element.hasClass(widget.classes.invert.x)).toBe(false)

  describe "resetY", ->
    it "should remove the Widget#classes.invert.y class from the Widget#element", ->
      widget.element.addClass(widget.classes.invert.y);
      widget.resetY()
      expect(widget.element.hasClass(widget.classes.invert.y)).toBe(false)
