h = require('helpers')
Range = require('xpath-range').Range

UI = require('../../../src/ui')
Util = require('../../../src/util')

$ = Util.$

describe 'UI.Editor', ->
  plugin = null

  describe 'in default configuration', ->

    beforeEach ->
      plugin = new UI.Editor()

    afterEach ->
      plugin.destroy()

    it 'should start hidden', ->
      assert.isFalse(plugin.isShown())

    describe '.show()', ->
      it 'should make the editor widget visible', ->
        plugin.show()
        assert.isTrue(plugin.isShown())

      it 'sets the widget position if a position is provided', ->
        plugin.show({
          top: '100px'
          left: '200px'
        })
        assert.deepEqual(
          {
            top: plugin.element[0].style.top
            left: plugin.element[0].style.left
          },
          {
            top: '100px'
            left: '200px'
          }
        )


    describe '.hide()', ->
      it 'should hide the editor widget', ->
        plugin.show()
        plugin.hide()
        assert.isFalse(plugin.isShown())


    describe '.destroy()', ->
      it 'should remove the editor from the document', ->
        plugin.destroy()
        assert.isFalse(document.body in plugin.element.parents())


    describe '.load(annotation)', ->

      it 'should show the widget', ->
        plugin.load({text: "Hello, world."})
        assert.isTrue(plugin.isShown())

      it 'should show the annotation text for editing', ->
        plugin.load({text: "Hello, world."})
        assert.equal(plugin.element.find('textarea').val(), "Hello, world.")

      it 'should return a promise that is resolved if the editor is
          subsequently submitted', (done) ->
        ann = {text: "Hello, world"}
        res = plugin.load(ann)

        plugin.element.find('textarea').val('Updated in the editor')
        plugin.submit()

        res
          .then ->
            assert.equal(ann.text, "Updated in the editor")
          .then(done, done)

      it 'should return a that is rejected if editing is
          subsequently cancelled', (done) ->
        ann = {text: "Hello, world"}
        res = plugin.load(ann)

        plugin.cancel()

        res
          .then(
            -> done(new Error("Promise should have been rejected!")),
            -> done()
          )
          .then(done, done)

    describe '.submit()', ->
      ann = null

      beforeEach ->
        ann = {text: "Giraffes are tall."}
        plugin.load(ann)

      it 'should hide the widget', ->
        plugin.submit()
        assert.isFalse(plugin.isShown())

      it 'should save any changes made to the annotation text', ->
        plugin.element.find('textarea').val('Lions are strong.')
        plugin.submit()
        assert.equal(ann.text, 'Lions are strong.')


    describe '.cancel()', ->
      ann = null

      beforeEach ->
        ann = {text: "Blue whales are large."}
        plugin.load(ann)

      it 'should hide the widget', ->
        plugin.submit()
        assert.isFalse(plugin.isShown())

      it 'should NOT save changes made to the annotation text', ->
        plugin.element.find('textarea').val('Mice are small.')
        plugin.cancel()
        assert.equal(ann.text, 'Blue whales are large.')


    describe 'custom fields', ->
      ann = null
      field = null
      elem = null

      beforeEach ->
        ann = {text: "Donkeys with beachballs"}
        field = {
          label: "Example field"
          load: sinon.spy()
          submit: sinon.spy()
        }
        elem = plugin.addField(field)

      it 'should call the load callback of added fields when an annotation is
          loaded into the editor', ->
        plugin.load(ann)
        sinon.assert.calledOnce(field.load)

      it 'should pass a DOM Node as the first argument to the load callback', ->
        plugin.load(ann)
        callArgs = field.load.args[0]
        assert.equal(callArgs[0].nodeType, 1)

      it 'should pass an annotation as the second argument to the load
          callback', ->
        plugin.load(ann)
        callArgs = field.load.args[0]
        assert.equal(callArgs[1], ann)

      it 'should return the created field element from .addField(field)', ->
        assert.equal(elem.nodeType, 1)

      it 'should add the plugin label to the field element', ->
        assert($(elem).html().indexOf('Example field') >= 0)

      it 'should add an <input> element by default', ->
        assert.equal($(elem).find(':input').prop('tagName'), 'INPUT')

      it 'should add a <textarea> element if type is "textarea"', ->
        elem2 = plugin.addField({
          label: "My textarea"
          type: "textarea"
          load: ->
          submit: ->
        })
        assert.equal($(elem2).find(':input').prop('tagName'), 'TEXTAREA')

      it 'should add a <select> element if type is "select"', ->
        elem2 = plugin.addField({
          label: "My select"
          type: "select"
          load: ->
          submit: ->
        })
        assert.equal($(elem2).find(':input').prop('tagName'), 'SELECT')

      it 'should add an <input type="checkbox"> element if type is
          "checkbox"', ->
        elem2 = plugin.addField({
          label: "My checkbox"
          type: "checkbox"
          load: ->
          submit: ->
        })
        assert.equal($(elem2).find(':input').prop('tagName'), 'INPUT')
        assert.equal($(elem2).find(':input').attr('type'), 'checkbox')

      it 'should call the submit callback of added fields when the editor
          is submitted', ->
        plugin.load(ann)
        plugin.submit()
        sinon.assert.calledOnce(field.submit)

      it 'should pass a DOM Node as the first argument to the submit
          callback', ->
        plugin.load(ann)
        plugin.submit()
        callArgs = field.submit.args[0]
        assert.equal(callArgs[0].nodeType, 1)

      it 'should pass an annotation as the second argument to the load
          callback', ->
        plugin.load(ann)
        plugin.submit()
        callArgs = field.submit.args[0]
        assert.equal(callArgs[1], ann)


  describe 'with the defaultFields option set to false', ->

    beforeEach ->
      plugin = new UI.Editor({
        defaultFields: false
      })

    afterEach ->
      plugin.destroy()

    it 'should not add the default fields', ->
      plugin.load({text: "Anteaters with torches"})
      assert.equal(
        plugin.element.html().indexOf("Anteaters with torches"),
        -1
      )


  describe 'event handlers', ->
    ann = null

    beforeEach ->
      plugin = new UI.Editor()
      ann = {text: 'Turtles with armbands'}

    afterEach ->
      plugin.destroy()

    it 'should submit when the editor form is submitted', ->
      plugin.load(ann)
      plugin.element.find('textarea').val('Turtles with bandanas')
      plugin.element.find('form').submit()
      assert.equal(ann.text, 'Turtles with bandanas')
      assert.isFalse(plugin.isShown())

    it 'should submit when the editor submit button is clicked', ->
      plugin.load(ann)
      plugin.element.find('textarea').val('Turtles with bandanas')
      plugin.element.find('.annotator-save').click()
      assert.equal(ann.text, 'Turtles with bandanas')
      assert.isFalse(plugin.isShown())

    it 'should cancel editing when the editor cancel button is clicked', ->
      plugin.load(ann)
      plugin.element.find('textarea').val('Turtles with bandanas')
      plugin.element.find('.annotator-cancel').click()
      assert.equal(ann.text, 'Turtles with armbands')
      assert.isFalse(plugin.isShown())

    it 'should submit when the user hits <Return> in the main textarea', ->
      plugin.load(ann)
      plugin.element.find('textarea')
      .val('Turtles with bandanas')
      .trigger({
        type: 'keydown'
        which: 13  # Return key
      })
      assert.equal(ann.text, 'Turtles with bandanas')
      assert.isFalse(plugin.isShown())

    it 'should NOT submit when the user hits <Shift>-<Return> in the main
        textarea', ->
      plugin.load(ann)
      plugin.element.find('textarea')
      .val('Turtles with bandanas')
      .trigger({
        type: 'keydown'
        which: 13  # Return key
        shiftKey: true
      })
      assert.equal(ann.text, 'Turtles with armbands')
      assert.isTrue(plugin.isShown())

    it 'should cancel editing when the user hits <Esc> in the main textarea', ->
      plugin.load(ann)
      plugin.element.find('textarea')
      .val('Turtles with bandanas')
      .trigger({
        type: 'keydown'
        which: 27  # Escape key
      })
      assert.equal(ann.text, 'Turtles with armbands')
      assert.isFalse(plugin.isShown())
