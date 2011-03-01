describe 'Annotator.Editor', ->
  editor = null;

  beforeEach ->
    editor = new Annotator.Editor()

  afterEach ->
    editor.element.remove()

  it "should have an element property", ->
    expect(editor.element).toBeTruthy()

    expect(editor.element.hasClass('annotator-editor')).toBeTruthy()

  describe "show", ->
    it "should make the editor visible", ->
      editor.show()
      expect(editor.element.hasClass('annotator-hide')).toBeFalsy()

  describe "hide", ->
    it "should hide the editor from view", ->
      editor.hide()
      expect(editor.element.hasClass('annotator-hide')).toBeTruthy()

  describe "load", ->
    beforeEach ->
      editor.annotation = {text: 'test'}
      editor.fields = [
        {
          element: 'element0',
          load: jasmine.createSpy()
        },
        {
          element: 'element1',
          load: jasmine.createSpy()
        }
      ]

    it "should call #show()", ->
      spyOn(editor, 'show');
      editor.load()
      expect(editor.show).toHaveBeenCalled()

    it "should set the current annotation", ->
      editor.load({text: 'Hello there'})
      expect(editor.annotation.text).toEqual('Hello there')

    it "should call the load callback on each field in the group", ->
      editor.load()
      expect(editor.fields[0].load).toHaveBeenCalled()
      expect(editor.fields[1].load).toHaveBeenCalled()

    it "should pass the field element and an annotation to the callback", ->
      editor.load()
      expect(editor.fields[0].load).toHaveBeenCalledWith(
        editor.fields[0].element,
        editor.annotation
      )

  describe "submit", ->
    beforeEach ->
      editor.annotation = {text: 'test'}
      editor.fields = [
        {
          element: 'element0',
          submit: jasmine.createSpy()
        },
        {
          element: 'element1',
          submit: jasmine.createSpy()
        }
      ]

    it "should call #hide()", ->
      spyOn(editor, 'hide');
      editor.submit()
      expect(editor.hide).toHaveBeenCalled()

    it "should call the submit callback on each field in the group", ->
      editor.submit()
      expect(editor.fields[0].submit).toHaveBeenCalled()
      expect(editor.fields[1].submit).toHaveBeenCalled()

    it "should pass the field element and an annotation to the callback", ->
      editor.submit()
      expect(editor.fields[0].submit).toHaveBeenCalledWith(
        editor.fields[0].element,
        editor.annotation
      )

  describe "addField", ->

    it "should append a new field to the @fields property", ->
      length = editor.fields.length

      editor.addField()
      expect(editor.fields.length).toEqual(length + 1)

      editor.addField()
      expect(editor.fields.length).toEqual(length + 2)

    it "should append a new list element to the editor", ->
      length = editor.element.find('li').length

      editor.addField()
      expect(editor.element.find('li').length).toEqual(length + 1)

      editor.addField()
      expect(editor.element.find('li').length).toEqual(length + 2)

    it "should append an input element if no type is specified", ->
      editor.addField()
      expect(editor.element.find('li:last :input').attr('type')).toEqual('text')

    it "should append a textarea element if 'textarea' type is specified", ->
      editor.addField({type: 'textarea'})
      expect(editor.element.find('li:last :input').attr('type')).toEqual('textarea')

    it "should append a checkbox element if 'checkbox' type is specified", ->
      editor.addField({type: 'checkbox'})
      expect(editor.element.find('li:last :input').attr('type')).toEqual('checkbox')

    it "should append a label element with a for attribute matching the checkbox id", ->
      editor.addField({type: 'checkbox'})
      expect(
        editor.element.find('li:last :input').attr('id')
      ).toEqual(
        editor.element.find('li:last label').attr('for')
      )

    it "should set placeholder text if a label is provided", ->
      editor.addField({type: 'textarea', label: 'Tags…'})
      expect(editor.element.find('li:last :input').attr('placeholder')).toEqual('Tags…')

    it "should return the created list item", ->
      expect(editor.addField().tagName).toEqual('LI')
