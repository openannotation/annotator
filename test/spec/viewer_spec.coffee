describe 'Annotator.Viewer', ->
  viewer = null

  beforeEach ->
    viewer = new Annotator.Viewer()

  afterEach ->
    viewer.element.remove()

  it "should have an element property", ->
    expect(viewer.element).toBeTruthy()

    expect(viewer.element.hasClass('annotator-viewer')).toBeTruthy()

  describe "an annotation element", ->
    it "should contain some controls", ->
      viewer.load([{text: "Hello there"}])
      expect(viewer.element.find('.annotator-controls:first button').length).toBeGreaterThan(0)

    it "should NOT contain any controls if options.readOnly is true", ->
      viewer = new Annotator.Viewer(readOnly: true)
      viewer.load([{text: "Hello there"}])
      expect(viewer.element.find('.annotator-controls:first button').length).toBe(0)

    it "should contain an external link to the annotation if the annotation provides one", ->
      viewer.load([{links:[{rel: "alternate", href: "http://example.com/foo", type: "text/html"}]}])
      expect(viewer.element.find('.annotator-controls:first a.annotator-link').attr('href')).toBe('http://example.com/foo')

    it "should NOT contain an external link to the annotation if the annotation doesn't provide one", ->
      viewer.load([{text: "Hello there"}])
      expect(viewer.element.find('.annotator-controls:first a.annotator-link').length).toBe(0)

  describe "events", ->
    beforeEach ->
      viewer.element.find('ul').append(viewer.html.item)

    it "should call Viewer#onEditClick() when the edit button is clicked", ->
      spyOn(viewer, 'onEditClick')
      viewer.element.find('.annotator-edit').click()
      expect(viewer.onEditClick).toHaveBeenCalled()

    it "should call Viewer#onDeleteClick() when the delete button is clicked", ->
      spyOn(viewer, 'onDeleteClick')
      viewer.element.find('.annotator-delete').click()
      expect(viewer.onDeleteClick).toHaveBeenCalled()

  describe "show", ->
    it "should make the viewer visible", ->
      viewer.show()
      expect(viewer.element.hasClass(viewer.classes.hide)).toBeFalsy()

  describe "isShown", ->
    it "should return true if the viewer is visible", ->
      viewer.show()
      expect(viewer.isShown()).toBeTruthy()

    it "should return false if the viewer is not visible", ->
      viewer.hide()
      expect(viewer.isShown()).toBeFalsy()

  describe "hide", ->
    it "should hide the viewer from view", ->
      viewer.hide()
      expect(viewer.element.hasClass(viewer.classes.hide)).toBeTruthy()

  describe "load", ->
    beforeEach ->
      viewer.annotations = [{text: 'test'}]
      viewer.fields = [
        {
          element: $('<div />')[0],
          load: jasmine.createSpy()
        },
        {
          element: $('<div />')[0],
          load: jasmine.createSpy()
        }
      ]
      viewer.load([{text: 'Hello there'}])

    it "should call #show()", ->
      spyOn(viewer, 'show');
      viewer.load()
      expect(viewer.show).toHaveBeenCalled()

    it "should set the current annotation", ->
      expect(viewer.annotations[0].text).toEqual('Hello there')

    it "should call the load callback on each field in the group", ->
      expect(viewer.fields[0].load).toHaveBeenCalled()
      expect(viewer.fields[1].load).toHaveBeenCalled()

    it "should pass the cloned field element and an annotation to the callback", ->
      # Have to find the element here as it is cloned on each iteration by the load function.
      args = viewer.fields[0].load.mostRecentCall.args

      expect(args[0]).toEqual(viewer.element.find('div:first')[0])
      expect(args[1]).toEqual(viewer.annotations[0])
      expect(args[2].showEdit).toBeTruthy()
      expect(args[2].hideEdit).toBeTruthy()
      expect(args[2].showDelete).toBeTruthy()
      expect(args[2].hideDelete).toBeTruthy()

  describe "addField", ->

    it "should append a new field to the @fields property", ->
      length = viewer.fields.length

      viewer.addField()
      expect(viewer.fields.length).toEqual(length + 1)

      viewer.addField()
      expect(viewer.fields.length).toEqual(length + 2)

  describe "onEditClick", ->
    it "should call onButtonClick and provide an event to trigger", ->
      spyOn(viewer, 'onButtonClick')

      event = {}
      viewer.onEditClick(event)

      expect(viewer.onButtonClick).toHaveBeenCalled()
      expect(viewer.onButtonClick).toHaveBeenCalledWith(event, 'edit')

  describe "onDeleteClick", ->
    it "should call onButtonClick and provide an event to trigger", ->
      spyOn(viewer, 'onButtonClick')

      event = {}
      viewer.onDeleteClick(event)

      expect(viewer.onButtonClick).toHaveBeenCalled()
      expect(viewer.onButtonClick).toHaveBeenCalledWith(event, 'delete')

  describe "onButtonClick", ->
    listener = null

    beforeEach ->
      listener = jasmine.createSpy()
      viewer.element.bind('edit', listener)

    it "should trigger an 'edit' event", ->
      viewer.onButtonClick({}, 'edit')
      expect(listener).toHaveBeenCalled()

    it "should pass in the annotation object associated with the item", ->
      annotation = {}
      item   = $('<div class="annotator-annotation" />').data('annotation', annotation)
      button = $('<button />').appendTo(item)[0]

      viewer.onButtonClick({target: button}, 'edit')

      # First argument will be an event so we must use a more convoluted method
      # of checking the annotation was passed.
      expect(listener.mostRecentCall.args[1]).toEqual(annotation)
