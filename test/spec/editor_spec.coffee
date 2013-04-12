describe 'Annotator.Editor', ->
  editor = null

  beforeEach ->
    editor = new Annotator.Editor()

  afterEach ->
    editor.element.remove()

  it "should have an element property", ->
    assert.ok(editor.element)
    assert.isTrue(editor.element.hasClass('annotator-editor'))

  describe "events", ->
    it "should call Editor#submit() when the form is submitted", ->
      sinon.spy(editor, 'submit')
      # Prevent the default form submission in the browser.
      editor.element.find('form').submit((e) -> e.preventDefault()).submit()
      assert(editor.submit.calledOnce)

    it "should call Editor#submit() when the save button is clicked", ->
      sinon.spy(editor, 'submit')
      editor.element.find('.annotator-save').click()
      assert(editor.submit.calledOnce)

    it "should call Editor#hide() when the cancel button is clicked", ->
      sinon.spy(editor, 'hide')
      editor.element.find('.annotator-cancel').click()
      assert(editor.hide.calledOnce)

    it "should call Editor#onCancelButtonMouseover() when mouse moves over cancel", ->
      sinon.spy(editor, 'onCancelButtonMouseover')
      editor.element.find('.annotator-cancel').mouseover()
      assert(editor.onCancelButtonMouseover.calledOnce)

    it "should call Editor#processKeypress() when a key is pressed in a textarea", ->
      # Editor needs a text area field.
      editor.element.find('ul').append('<li><textarea></textarea></li>')

      sinon.spy(editor, 'processKeypress')
      editor.element.find('textarea').keydown()
      assert(editor.processKeypress.calledOnce)

  describe "show", ->
    it "should make the editor visible", ->
      editor.show()
      assert.isFalse(editor.element.hasClass('annotator-hide'))

    it "should publish the 'show' event", ->
      sinon.spy(editor, 'publish')
      editor.show()
      assert.isTrue(editor.publish.calledWith('show'))

  describe "hide", ->
    it "should hide the editor from view", ->
      editor.hide()
      assert.isTrue(editor.element.hasClass('annotator-hide'))

    it "should publish the 'show' event", ->
      sinon.spy(editor, 'publish')
      editor.hide()
      assert.isTrue(editor.publish.calledWith('hide'))

  describe "load", ->
    beforeEach ->
      editor.annotation = {text: 'test'}
      editor.fields = [
        {
          element: 'element0',
          load: sinon.spy()
        },
        {
          element: 'element1',
          load: sinon.spy()
        }
      ]

      # TODO: investigate why the following tests fail (editor.load blocks)
      #       unless the following has been called.
      # sinon.spy(editor, 'show')

    it "should call #show()", ->
      sinon.spy(editor, 'show')
      editor.load()
      assert(editor.show.calledOnce)

    it "should set the current annotation", ->
      editor.load({text: 'Hello there'})
      assert.equal(editor.annotation.text, 'Hello there')

    it "should call the load callback on each field in the group", ->
      editor.load()
      assert(editor.fields[0].load.calledOnce)
      assert(editor.fields[1].load.calledOnce)

    it "should pass the field element and an annotation to the callback", ->
      editor.load()
      assert(editor.fields[0].load.calledWith(editor.fields[0].element, editor.annotation))

    it "should publish the 'load' event", ->
      sinon.spy(editor, 'publish')
      editor.load()
      assert.isTrue(editor.publish.calledWith('load', [editor.annotation]))

  describe "submit", ->
    beforeEach ->
      editor.annotation = {text: 'test'}
      editor.fields = [
        {
          element: 'element0',
          submit: sinon.spy()
        },
        {
          element: 'element1',
          submit: sinon.spy()
        }
      ]

    it "should call #hide()", ->
      sinon.spy(editor, 'hide')
      editor.submit()
      assert(editor.hide.calledOnce)

    it "should call the submit callback on each field in the group", ->
      editor.submit()
      assert(editor.fields[0].submit.calledOnce)
      assert(editor.fields[1].submit.calledOnce)

    it "should pass the field element and an annotation to the callback", ->
      editor.submit()
      assert(editor.fields[0].submit.calledWith(editor.fields[0].element, editor.annotation))

    it "should publish the 'save' event", ->
      sinon.spy(editor, 'publish')
      editor.submit()
      assert.isTrue(editor.publish.calledWith('save', [editor.annotation]))

  describe "addField", ->
    content = null

    beforeEach -> content = editor.element.children()

    afterEach ->
      editor.element.empty().append(content)
      editor.fields = []

    it "should append a new field to the @fields property", ->
      length = editor.fields.length

      editor.addField()
      assert.lengthOf(editor.fields, length + 1)

      editor.addField()
      assert.lengthOf(editor.fields, length + 2)

    it "should append a new list element to the editor", ->
      length = editor.element.find('li').length

      editor.addField()
      assert.lengthOf(editor.element.find('li'), length + 1)

      editor.addField()
      assert.lengthOf(editor.element.find('li'), length + 2)

    it "should append an input element if no type is specified", ->
      editor.addField()
      assert.equal(editor.element.find('li:last :input').prop('type'), 'text')

    it "should give each element a new id", ->
      editor.addField()
      firstID = editor.element.find('li:last :input').attr('id')

      editor.addField()
      secondID = editor.element.find('li:last :input').attr('id')
      assert.notEqual(firstID, secondID)

    it "should append a textarea element if 'textarea' type is specified", ->
      editor.addField({type: 'textarea'})
      assert.equal(editor.element.find('li:last :input').prop('type'), 'textarea')

    it "should append a checkbox element if 'checkbox' type is specified", ->
      editor.addField({type: 'checkbox'})
      assert.equal(editor.element.find('li:last :input').prop('type'), 'checkbox')

    it "should append a label element with a for attribute matching the checkbox id", ->
      editor.addField({type: 'checkbox'})
      assert.equal(
        editor.element.find('li:last :input').attr('id'),
        editor.element.find('li:last label').attr('for')
      )

    it "should set placeholder text if a label is provided", ->
      editor.addField({type: 'textarea', label: 'Tags…'})
      assert.equal(editor.element.find('li:last :input').attr('placeholder'), 'Tags…')

    it "should return the created list item", ->
      assert.equal(editor.addField().tagName, 'LI')

  describe "processKeypress", ->
    beforeEach ->
      sinon.spy(editor, 'hide')
      sinon.spy(editor, 'submit')

    it "should call Editor#hide() if the escape key is pressed", ->
      editor.processKeypress({keyCode: 27})
      assert(editor.hide.calledOnce)

    it "should call Editor#submit() if the enter key is pressed", ->
      editor.processKeypress({keyCode: 13})
      assert(editor.submit.calledOnce)

    it "should NOT call Editor#submit() if the shift key is held down", ->
      editor.processKeypress({keyCode: 13, shiftKey: true})
      assert.isFalse(editor.submit.called)

  describe "onCancelButtonMouseover", ->
    it "should remove the focus class from submit when cancel is hovered", ->
      editor.element.find('.annotator-save').addClass('annotator-focus')
      editor.onCancelButtonMouseover()
      assert.lengthOf(editor.element.find('.annotator-focus'), 0)
