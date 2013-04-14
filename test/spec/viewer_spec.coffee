describe 'Annotator.Viewer', ->
  viewer = null

  beforeEach ->
    viewer = new Annotator.Viewer()

  afterEach ->
    viewer.element.remove()

  it "should have an element property", ->
    assert.ok(viewer.element)
    assert.isTrue(viewer.element.hasClass('annotator-viewer'))

  describe "an annotation element", ->
    it "should contain some controls", ->
      viewer.load([{text: "Hello there"}])
      assert.operator(viewer.element.find('.annotator-controls:first button').length, '>', 0)

    it "should NOT contain any controls if options.readOnly is true", ->
      viewer = new Annotator.Viewer(readOnly: true)
      viewer.load([{text: "Hello there"}])
      assert.lengthOf(viewer.element.find('.annotator-controls:first button'), 0)

    it "should contain an external link to the annotation if the annotation provides one", ->
      viewer.load([{links:[{rel: "alternate", href: "http://example.com/foo", type: "text/html"}]}])
      assert.equal(viewer.element.find('.annotator-controls:first a.annotator-link').attr('href'), 'http://example.com/foo')

    it "should NOT contain an external link to the annotation if the annotation doesn't provide one", ->
      viewer.load([{text: "Hello there"}])
      assert.lengthOf(viewer.element.find('.annotator-controls:first a.annotator-link'), 0)

  describe "events", ->
    beforeEach ->
      viewer.element.find('ul').append(viewer.html.item)

    it "should call Viewer#onEditClick() when the edit button is clicked", ->
      sinon.spy(viewer, 'onEditClick')
      viewer.element.find('.annotator-edit').click()
      assert(viewer.onEditClick.calledOnce)

    it "should call Viewer#onDeleteClick() when the delete button is clicked", ->
      sinon.spy(viewer, 'onDeleteClick')
      viewer.element.find('.annotator-delete').click()
      assert(viewer.onDeleteClick.calledOnce)

  describe "show", ->
    it "should make the viewer visible", ->
      viewer.show()
      assert.isFalse(viewer.element.hasClass(viewer.classes.hide))

  describe "isShown", ->
    it "should return true if the viewer is visible", ->
      viewer.show()
      assert.isTrue(viewer.isShown())

    it "should return false if the viewer is not visible", ->
      viewer.hide()
      assert.isFalse(viewer.isShown())

  describe "hide", ->
    it "should hide the viewer from view", ->
      viewer.hide()
      assert.isTrue(viewer.element.hasClass(viewer.classes.hide))

  describe "load", ->
    beforeEach ->
      viewer.annotations = [{text: 'test'}]
      viewer.fields = [
        {
          element: $('<div />')[0],
          load: sinon.spy()
        },
        {
          element: $('<div />')[0],
          load: sinon.spy()
        }
      ]
      viewer.load([{text: 'Hello there'}])

    it "should call #show()", ->
      sinon.spy(viewer, 'show')
      viewer.load()
      assert(viewer.show.calledOnce)

    it "should set the current annotation", ->
      assert.equal(viewer.annotations[0].text, 'Hello there')

    it "should call the load callback on each field in the group", ->
      assert(viewer.fields[0].load.calledOnce)
      assert(viewer.fields[1].load.calledOnce)

    it "should pass the cloned field element and an annotation to the callback", ->
      # Have to find the element here as it is cloned on each iteration by the load function.
      args = viewer.fields[0].load.lastCall.args

      assert.equal(args[0], viewer.element.find('div:first')[0])
      assert.equal(args[1], viewer.annotations[0])
      assert.ok(args[2].showEdit)
      assert.ok(args[2].hideEdit)
      assert.ok(args[2].showDelete)
      assert.ok(args[2].hideDelete)

  describe "addField", ->

    it "should append a new field to the @fields property", ->
      length = viewer.fields.length

      viewer.addField()
      assert.lengthOf(viewer.fields, length + 1)

      viewer.addField()
      assert.lengthOf(viewer.fields, length + 2)

  describe "onEditClick", ->
    it "should call onButtonClick and provide an event to trigger", ->
      sinon.spy(viewer, 'onButtonClick')

      event = {}
      viewer.onEditClick(event)

      assert(viewer.onButtonClick.calledOnce)
      assert.isTrue(viewer.onButtonClick.calledWith(event, 'edit'))

  describe "onDeleteClick", ->
    it "should call onButtonClick and provide an event to trigger", ->
      sinon.spy(viewer, 'onButtonClick')

      event = {}
      viewer.onDeleteClick(event)

      assert(viewer.onButtonClick.calledOnce)
      assert.isTrue(viewer.onButtonClick.calledWith(event, 'delete'))

  describe "onButtonClick", ->
    listener = null

    beforeEach ->
      listener = sinon.spy()
      viewer.element.bind('edit', listener)

    it "should trigger an 'edit' event", ->
      viewer.onButtonClick({}, 'edit')
      assert(listener.calledOnce)

    it "should pass in the annotation object associated with the item", ->
      annotation = {}
      item   = $('<div class="annotator-annotation" />').data('annotation', annotation)
      button = $('<button />').appendTo(item)[0]

      viewer.onButtonClick({target: button}, 'edit')

      # First argument will be an event so we must use a more convoluted method
      # of checking the annotation was passed.
      assert.equal(listener.lastCall.args[1], annotation)
