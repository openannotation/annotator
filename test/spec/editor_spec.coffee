describe 'Annotator.Editor', ->
  editor = null

  beforeEach ->
    editor = new Annotator.Editor()

  afterEach ->
    editor.element.remove()

  it "should have an element property", ->
    expect(editor.element).toBeTruthy()
    expect(editor.element.hasClass('annotator-editor')).toBeTruthy()

  describe "events", ->
    it "should call Editor#submit() when the form is submitted", ->
      spyOn(editor, 'submit')
      # Prevent the default form submission in the browser.
      editor.element.find('form').submit((e) -> e.preventDefault()).submit()
      expect(editor.submit).toHaveBeenCalled()

    it "should call Editor#submit() when the save button is clicked", ->
      spyOn(editor, 'submit')
      editor.element.find('.annotator-save').click()
      expect(editor.submit).toHaveBeenCalled()

    it "should call Editor#hide() when the cancel button is clicked", ->
      spyOn(editor, 'hide')
      editor.element.find('.annotator-cancel').click()
      expect(editor.hide).toHaveBeenCalled()

    it "should call Editor#onCancelButtonMouseover() when mouse moves over cancel", ->
      spyOn(editor, 'onCancelButtonMouseover')
      editor.element.find('.annotator-cancel').mouseover()
      expect(editor.onCancelButtonMouseover).toHaveBeenCalled()

    it "should call Editor#processKeypress() when a key is pressed in a textarea", ->
      # Editor needs a text area field.
      editor.element.find('ul').append('<li><textarea></textarea></li>')

      spyOn(editor, 'processKeypress')
      editor.element.find('textarea').keydown()
      expect(editor.processKeypress).toHaveBeenCalled()

  describe "show", ->
    it "should make the editor visible", ->
      editor.show()
      expect(editor.element.hasClass('annotator-hide')).toBeFalsy()

    it "should publish the 'show' event", ->
      spyOn(editor, 'publish')
      editor.show()
      expect(editor.publish).toHaveBeenCalledWith('show')

  describe "hide", ->
    it "should hide the editor from view", ->
      editor.hide()
      expect(editor.element.hasClass('annotator-hide')).toBeTruthy()

    it "should publish the 'show' event", ->
      spyOn(editor, 'publish')
      editor.hide()
      expect(editor.publish).toHaveBeenCalledWith('hide')

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

      # TODO: investigate why the following tests fail (editor.load blocks)
      #       unless the following has been called.
      # spyOn(editor, 'show')

    it "should call #show()", ->
      spyOn(editor, 'show')
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

    it "should publish the 'load' event", ->
      spyOn(editor, 'publish')
      editor.load()
      expect(editor.publish).toHaveBeenCalledWith('load', [editor.annotation])

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

    it "should publish the 'save' event", ->
      spyOn(editor, 'publish')
      editor.submit()
      expect(editor.publish).toHaveBeenCalledWith('save', [editor.annotation])

  describe "addField", ->
    content = null

    beforeEach -> content = editor.element.children()

    afterEach ->
      editor.element.empty().append(content)
      editor.fields = []

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
      expect(editor.element.find('li:last :input').prop('type')).toEqual('text')

    it "should give each element a new id", ->
      editor.addField()
      firstID = editor.element.find('li:last :input').attr('id')

      editor.addField()
      secondID = editor.element.find('li:last :input').attr('id')
      expect(firstID).not.toEqual(secondID)

    it "should append a textarea element if 'textarea' type is specified", ->
      editor.addField({type: 'textarea'})
      expect(editor.element.find('li:last :input').prop('type')).toEqual('textarea')

    it "should append a checkbox element if 'checkbox' type is specified", ->
      editor.addField({type: 'checkbox'})
      expect(editor.element.find('li:last :input').prop('type')).toEqual('checkbox')

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

  describe "processKeypress", ->
    beforeEach ->
      spyOn(editor, 'hide')
      spyOn(editor, 'submit')

    it "should call Editor#hide() if the escape key is pressed", ->
      editor.processKeypress({keyCode: 27})
      expect(editor.hide).toHaveBeenCalled()

    it "should call Editor#submit() if the enter key is pressed", ->
      editor.processKeypress({keyCode: 13})
      expect(editor.submit).toHaveBeenCalled()

    it "should NOT call Editor#submit() if the shift key is held down", ->
      editor.processKeypress({keyCode: 13, shiftKey: true})
      expect(editor.submit).not.toHaveBeenCalled()

  describe "onCancelButtonMouseover", ->
    it "should remove the focus class from submit when cancel is hovered", ->
      editor.element.find('.annotator-save').addClass('annotator-focus')
      editor.onCancelButtonMouseover()
      expect(editor.element.find('.annotator-focus').length).toBe(0)
