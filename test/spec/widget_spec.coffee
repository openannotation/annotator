describe "Annotator.Widget", ->
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
