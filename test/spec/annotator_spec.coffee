describe 'Annotator', ->
  annotator = null

  beforeEach -> annotator = new Annotator($('<div></div>')[0], {})
  afterEach  -> $(document).unbind()

  describe "events", ->
    it "should call Annotator#onAdderClick() when adder is clicked", ->
      spyOn(annotator, 'onAdderClick')
      annotator.element.find('.annotator-adder button').click()
      expect(annotator.onAdderClick).toHaveBeenCalled()

    it "should call Annotator#onAdderMousedown() when mouse button is held down on adder", ->
      spyOn(annotator, 'onAdderMousedown')
      annotator.element.find('.annotator-adder button').mousedown()
      expect(annotator.onAdderMousedown).toHaveBeenCalled()

    it "should call Annotator#onHighlightMouseover() when mouse moves over a highlight", ->
      spyOn(annotator, 'onHighlightMouseover')

      highlight = $('<span class="annotator-hl" />').appendTo(annotator.element)
      highlight.mouseover()

      expect(annotator.onHighlightMouseover).toHaveBeenCalled()

    it "should call Annotator#startViewerHideTimer() when mouse moves off a highlight", ->
      spyOn(annotator, 'startViewerHideTimer')

      highlight = $('<span class="annotator-hl" />').appendTo(annotator.element)
      highlight.mouseout()

      expect(annotator.startViewerHideTimer).toHaveBeenCalled()

  describe "constructor", ->
    beforeEach ->
      spyOn(annotator, '_setupWrapper').andReturn(annotator)
      spyOn(annotator, '_setupViewer').andReturn(annotator)
      spyOn(annotator, '_setupEditor').andReturn(annotator)
      spyOn(annotator, '_setupDocumentEvents').andReturn(annotator)

    it "should have a jQuery wrapper as @element", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      expect(annotator.element instanceof $).toBeTruthy()

    it "should create an empty @plugin object", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      expect(annotator.hasOwnProperty('plugins')).toBeTruthy()

    it "should create the adder and highlight properties from the @html strings", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      expect(annotator.adder instanceof $).toBeTruthy()
      expect(annotator.hl instanceof $).toBeTruthy()

    it "should call Annotator#_setupWrapper()", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      expect(annotator._setupWrapper).toHaveBeenCalled()

    it "should call Annotator#_setupViewer()", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      expect(annotator._setupViewer).toHaveBeenCalled()

    it "should call Annotator#_setupEditor()", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      expect(annotator._setupEditor).toHaveBeenCalled()

    it "should call Annotator#_setupDocumentEvents()", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      expect(annotator._setupDocumentEvents).toHaveBeenCalled()

    it "should NOT call Annotator#_setupDocumentEvents() if options.readOnly is true", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0], {
        readOnly: true
      })
      expect(annotator._setupDocumentEvents).not.toHaveBeenCalled()

  describe "_setupDocumentEvents", ->
    beforeEach: ->
      $(document).unbind('mouseup').unbind('mousedown')

    it "should call Annotator#checkForStartSelection() when mouse button is pressed", ->
      spyOn(annotator, 'checkForStartSelection')
      annotator._setupDocumentEvents()
      $(document).mousedown()
      expect(annotator.checkForStartSelection).toHaveBeenCalled()

    it "should call Annotator#checkForEndSelection() when mouse button is lifted", ->
      spyOn(annotator, 'checkForEndSelection')
      annotator._setupDocumentEvents()
      $(document).mouseup()
      expect(annotator.checkForEndSelection).toHaveBeenCalled()

  describe "_setupWrapper", ->
    it "should wrap children of @element in the @html.wrapper element", ->
      annotator.element = $('<div><span>contents</span></div>')
      annotator._setupWrapper()
      expect(annotator.wrapper.html()).toBe('<span>contents</span>')

    it "should remove all script elements prior to wrapping", ->
      div = document.createElement('div')
      div.appendChild(document.createElement('script'))

      annotator.element = $(div)
      annotator._setupWrapper()

      expect(annotator.wrapper[0].innerHTML).toBe('')

  describe "_setupViewer", ->
    mockViewer = null

    beforeEach ->
      element = $('<div />')

      mockViewer = {
        fields: []
        element: element
        addField: jasmine.createSpy('Viewer#addField()')
        hide: jasmine.createSpy('Viewer#hide()')
        on: jasmine.createSpy('Viewer#on()')
      }
      mockViewer.on.andReturn(mockViewer)
      mockViewer.hide.andReturn(mockViewer)
      mockViewer.addField.andCallFake (options) ->
        mockViewer.fields.push options
        mockViewer

      spyOn(element, 'bind').andReturn(element)
      spyOn(element, 'appendTo').andReturn(element)
      spyOn(Annotator, 'Viewer').andReturn(mockViewer)

      annotator._setupViewer()

    it "should create a new instance of Annotator.Viewer and set Annotator#viewer", ->
      expect(annotator.viewer).toBe(mockViewer)

    it "should hide the annotator on creation", ->
      expect(mockViewer.hide).toHaveBeenCalled()

    it "should setup the default text field", ->
      args = mockViewer.addField.mostRecentCall.args[0]

      expect(mockViewer.addField).toHaveBeenCalled()
      expect(typeof args.load).toBe("function")

    it "should set the contents of the field on load", ->
      field = document.createElement('div')
      annotation = {text: "test"}
      callback = jasmine.createSpy('callback')

      annotator.viewer.fields[0].load(field, annotation)
      expect(jQuery(field).html()).toBe("test")

    it "should set the contents of the field to placeholder text when empty", ->
      field = document.createElement('div')
      annotation = {text: ""}
      callback = jasmine.createSpy('callback')

      annotator.viewer.fields[0].load(field, annotation)
      expect(jQuery(field).html()).toBe("<i>No Comment</i>")

    it "should setup the default text field to publish an event on load", ->
      field = document.createElement('div')
      annotation = {text: "test"}
      callback = jasmine.createSpy('callback')

      annotator.on('annotationViewerTextField', callback)
      annotator.viewer.fields[0].load(field, annotation)
      expect(callback).toHaveBeenCalledWith(field, annotation)

    it "should subscribe to custom events", ->
      expect(mockViewer.on).toHaveBeenCalledWith('edit', annotator.onEditAnnotation)
      expect(mockViewer.on).toHaveBeenCalledWith('delete', annotator.onDeleteAnnotation)

    it "should bind to browser mouseover and mouseout events", ->
      expect(mockViewer.element.bind).toHaveBeenCalledWith({
        'mouseover': annotator.clearViewerHideTimer
        'mouseout':  annotator.startViewerHideTimer
      })

    it "should append the Viewer#element to the Annotator#wrapper", ->
      expect(mockViewer.element.appendTo).toHaveBeenCalledWith(annotator.wrapper)

  describe "_setupEditor", ->
    mockEditor = null

    beforeEach ->
      element = $('<div />')

      mockEditor = {
        element: element
        addField: jasmine.createSpy('Editor#addField()')
        hide: jasmine.createSpy('Editor#hide()')
        on: jasmine.createSpy('Editor#on()')
      }
      mockEditor.on.andReturn(mockEditor)
      mockEditor.hide.andReturn(mockEditor)
      mockEditor.addField.andReturn(document.createElement('li'))

      spyOn(element, 'appendTo').andReturn(element)
      spyOn(Annotator, 'Editor').andReturn(mockEditor)

      annotator._setupEditor()

    it "should create a new instance of Annotator.Editor and set Annotator#editor", ->
      expect(annotator.editor).toBe(mockEditor)

    it "should hide the annotator on creation", ->
      expect(mockEditor.hide).toHaveBeenCalled()

    it "should add the default textarea field", ->
      options = mockEditor.addField.mostRecentCall.args[0]

      expect(mockEditor.addField).toHaveBeenCalled()
      expect(options.type).toBe('textarea')
      expect(options.label).toBe('Comments\u2026')
      expect(typeof options.load).toBe('function')
      expect(typeof options.submit).toBe('function')

    it "should subscribe to custom events", ->
      expect(mockEditor.on).toHaveBeenCalledWith('hide', annotator.onEditorHide)
      expect(mockEditor.on).toHaveBeenCalledWith('save', annotator.onEditorSubmit)

    it "should append the Editor#element to the Annotator#wrapper", ->
      expect(mockEditor.element.appendTo).toHaveBeenCalledWith(annotator.wrapper)

  describe "getSelectedRanges", ->
    mockGlobal = null
    mockSelection = null
    mockRange = null
    mockBrowserRange = null

    beforeEach ->
      mockBrowserRange = {
        cloneRange: jasmine.createSpy('Range#cloneRange()')
      }
      mockBrowserRange.cloneRange.andReturn(mockBrowserRange)

      # This mock pretends to be both NomalizedRange and BrowserRange.
      mockRange = {
        limit: jasmine.createSpy('NormalizedRange#limit()')
        normalize: jasmine.createSpy('BrowserRange#normalize()')
        toRange: jasmine.createSpy('NormalizedRange#toRange()').andReturn('range')
      }
      mockRange.limit.andReturn(mockRange)
      mockRange.normalize.andReturn(mockRange)

      # https://developer.mozilla.org/en/nsISelection
      mockSelection = {
        getRangeAt: jasmine.createSpy('Selection#getRangeAt()').andReturn(mockBrowserRange)
        removeAllRanges: jasmine.createSpy('Selection#removeAllRanges()')
        addRange: jasmine.createSpy('Selection#addRange()')
        rangeCount: 1
      }
      mockGlobal = {
        getSelection: jasmine.createSpy('window.getSelection()').andReturn(mockSelection)
      }
      spyOn(util, 'getGlobal').andReturn(mockGlobal)
      spyOn(Range, 'BrowserRange').andReturn(mockRange)

    it "should retrieve the global object and call getSelection()", ->
      annotator.getSelectedRanges()
      expect(mockGlobal.getSelection).toHaveBeenCalled()

    it "should retrieve the global object and call getSelection()", ->
      ranges = annotator.getSelectedRanges()
      expect(ranges).toEqual([mockRange])

    it "should remove any failed calls to NormalizedRange#limit(), but re-add them to the global selection", ->
      mockRange.limit.andReturn(null)
      ranges = annotator.getSelectedRanges()
      expect(ranges).toEqual([])
      expect(mockSelection.addRange).toHaveBeenCalledWith(mockBrowserRange)

    it "should return an empty array if selection.isCollapsed is true", ->
      mockSelection.isCollapsed = true
      ranges = annotator.getSelectedRanges()
      expect(ranges).toEqual([])

    it "should deselect all current ranges", ->
      ranges = annotator.getSelectedRanges()
      expect(mockSelection.removeAllRanges).toHaveBeenCalled()

    it "should reassign the newly normalized ranges", ->
      ranges = annotator.getSelectedRanges()
      expect(mockSelection.addRange).toHaveBeenCalled()
      expect(mockSelection.addRange).toHaveBeenCalledWith('range')

  describe "createAnnotation", ->
    it "should return an empty annotation", ->
      expect(annotator.createAnnotation()).toEqual({})

    it "should fire the 'beforeAnnotationCreated' event providing the annotation", ->
      spyOn(annotator, 'publish')
      annotator.createAnnotation()
      expect(annotator.publish).toHaveBeenCalledWith('beforeAnnotationCreated', [{}])

  describe "setupAnnotation", ->
    annotation = null
    quote = null
    comment = null
    element = null
    annotationObj = null
    normalizedRange = null
    sniffedRange= null

    beforeEach ->
      quote   = 'This is some annotated text'
      comment = 'This is a comment on an annotation'
      element = $('<span />')

      normalizedRange = {
        text: jasmine.createSpy('normalizedRange#text()').andReturn(quote)
        serialize: jasmine.createSpy('normalizedRange#serialize()').andReturn({})
      }
      sniffedRange = {
        normalize: jasmine.createSpy('sniffedRange#normalize()').andReturn(normalizedRange)
      }
      spyOn(Range, 'sniff').andReturn(sniffedRange)
      spyOn(annotator, 'highlightRange').andReturn(element)
      spyOn(annotator, 'publish')

      annotationObj = {
        text: comment,
        ranges: [1]
      }
      annotation = annotator.setupAnnotation(annotationObj)

    it "should return the annotation object with a comment", ->
      expect(annotation.text).toEqual(comment)

    it "should return the annotation object with the quoted text", ->
      expect(annotation.quote).toEqual(quote)

    it "should trim whitespace from start and end of quote", ->
      normalizedRange.text.andReturn('\n\t   ' + quote + '   \n')
      annotation = annotator.setupAnnotation(annotationObj)
      expect(annotation.quote).toEqual(quote)

    it "should set the annotation.ranges", ->
      expect(annotation.ranges).toEqual([{}])

    it "should exclude any ranges that could not be normalised", ->
      sniffedRange.normalize = jasmine.createSpy('sniffedRange#normalize()').andReturn(null)
      annotation = annotator.setupAnnotation({
        text: comment,
        ranges: [1, 2]
      })
      expect(annotation.ranges).toEqual([])

    it "should call Annotator#highlightRange() with the normed range", ->
      expect(annotator.highlightRange).toHaveBeenCalledWith(normalizedRange)

    it "should store the annotation in the highlighted element's data store", ->
      expect(element.data('annotation')).toBe(annotation)

    it "should publish the 'annotationCreated' event", ->
      expect(annotator.publish).toHaveBeenCalledWith('annotationCreated', [annotation])

    it "should NOT publish the 'annotationCreated' event if fireEvents is false", ->
      annotator.setupAnnotation(annotationObj, false)
      expect(annotator.publish.callCount).toBe(1)

  describe "updateAnnotation", ->
    it "should publish the 'beforeAnnotationUpdated' and 'annotationUpdated' events", ->
      annotation = {text: "my annotation comment"}
      spyOn(annotator, 'publish')
      annotator.updateAnnotation(annotation)

      expect(annotator.publish).toHaveBeenCalledWith('beforeAnnotationUpdated', [annotation])
      expect(annotator.publish).toHaveBeenCalledWith('annotationUpdated', [annotation])

  describe "deleteAnnotation", ->
    annotation = null
    div = null

    beforeEach ->
      annotation = {
        text: "my annotation comment"
        highlights: $('<span><em>Hats</em></span><span><em>Gloves</em></span>')
      }
      div = $('<div />').append(annotation.highlights)

    it "should remove the highlights from the DOM", ->
      spyOn(annotator, 'publish')
      annotation.highlights.each ->
        expect($(this).parent().length).toBe(1)

      annotator.deleteAnnotation(annotation)
      annotation.highlights.each ->
        expect($(this).parent().length).toBe(0)

    it "should leave the content of the highlights in place", ->
      spyOn(annotator, 'publish')
      annotator.deleteAnnotation(annotation)
      expect(div.html()).toBe('<em>Hats</em><em>Gloves</em>')

    it "should publish the 'annotationDeleted' event", ->
      spyOn(annotator, 'publish')
      annotator.deleteAnnotation(annotation)
      expect(annotator.publish).toHaveBeenCalledWith('annotationDeleted', [annotation])

  describe "loadAnnotations", ->
    beforeEach ->
      spyOn(annotator, 'setupAnnotation')
      spyOn(annotator, 'publish')

    it "should call Annotator#setupAnnotation for each annotation in the Array", ->
      annotations = [{}, {}, {}, {}]
      annotator.loadAnnotations(annotations)
      expect(annotator.setupAnnotation.callCount).toBe(4)

    it "should publish the annotationsLoaded event with all loaded annotations", ->
      annotations = [{}, {}, {}, {}]
      annotator.loadAnnotations(annotations.slice())
      expect(annotator.publish).toHaveBeenCalledWith('annotationsLoaded', [annotations])

    it "should suppress the 'annotationCreated' event", ->
      annotations = [{}]
      annotator.loadAnnotations(annotations)
      expect(annotator.setupAnnotation).toHaveBeenCalledWith({}, false)

    it "should break the annotations into blocks of 10", ->
      annotations = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]
      count = annotations.length

      annotator.loadAnnotations(annotations)
      expect(annotator.setupAnnotation.callCount).toBe(10)

      waitsFor ->
        !annotations.length

      runs ->
        expect(annotator.setupAnnotation.callCount).toBe(13)

  describe "dumpAnnotations", ->
    it "returns false and prints a warning if no Store plugin is active", ->
      spyOn(console, 'warn')
      expect(annotator.dumpAnnotations()).toBeFalsy()
      expect(console.warn).toHaveBeenCalled()

    it "returns the results of the Store plugins dumpAnnotations method", ->
      annotator.plugins.Store = { dumpAnnotations: -> [1,2,3] }
      expect(annotator.dumpAnnotations()).toEqual([1,2,3])

  describe "highlightRange", ->
    it "should return a highlight element for every textNode in the range", ->
      textNodes = (document.createTextNode(text) for text in ['hello', 'world'])
      mockRange =
        textNodes: -> textNodes

      elements = annotator.highlightRange(mockRange)
      expect(elements.length).toBe(2)
      expect(elements[0].className).toBe('annotator-hl')
      expect(elements[0].firstChild).toBe(textNodes[0])
      expect(elements[1].firstChild).toBe(textNodes[1])

    it "should ignore textNodes that contain only whitespace", ->
      textNodes = (document.createTextNode(text) for text in ['hello', '\n ', '      '])
      mockRange =
        textNodes: -> textNodes

      elements = annotator.highlightRange(mockRange)
      expect(elements.length).toBe(1)
      expect(elements[0].className).toBe('annotator-hl')
      expect(elements[0].firstChild).toBe(textNodes[0])

  describe "addPlugin", ->
    plugin = null

    beforeEach ->
      plugin = {
        pluginInit: jasmine.createSpy('Plugin#pluginInit()')
      }
      Annotator.Plugin.Foo = jasmine.createSpy('Plugin#constructor()').andReturn(plugin)

    it "should add and instantiate a plugin of the specified name", ->
      annotator.addPlugin('Foo')
      expect(Annotator.Plugin.Foo).toHaveBeenCalledWith(annotator.element[0], undefined)

    it "should pass on the provided options", ->
      options = {foo: 'bar'}
      annotator.addPlugin('Foo', options)
      expect(Annotator.Plugin.Foo).toHaveBeenCalledWith(annotator.element[0], options)

    it "should attach the Annotator instance", ->
      annotator.addPlugin('Foo')
      expect(plugin.annotator).toBe(annotator)

    it "should call Plugin#pluginInit()", ->
      annotator.addPlugin('Foo')
      expect(plugin.pluginInit).toHaveBeenCalled()

    it "should complain if you try and instantiate a plugin twice", ->
      spyOn(console, 'error')
      annotator.addPlugin('Foo')
      annotator.addPlugin('Foo')
      expect(Annotator.Plugin.Foo.callCount).toBe(1)
      expect(console.error).toHaveBeenCalled()

    it "should complain if you try and instantiate a plugin that doesn't exist", ->
      spyOn(console, 'error')
      annotator.addPlugin('Bar')
      expect(annotator.plugins['Bar']?).toBeFalsy()
      expect(console.error).toHaveBeenCalled()

  describe "showEditor", ->
    beforeEach ->
      spyOn(annotator.editor, 'load')
      spyOn(annotator.editor.element, 'css')

    it "should call Editor#load() on the Annotator#editor", ->
      annotation = {text: 'my annotation comment'}
      annotator.showEditor(annotation, {})
      expect(annotator.editor.load).toHaveBeenCalledWith(annotation)

    it "should set the top/left properties of the Editor#element", ->
      location = {top: 20, left: 20}
      annotator.showEditor({}, location)
      expect(annotator.editor.element.css).toHaveBeenCalledWith(location)

  describe "onEditorHide", ->
    it "should publish the 'annotationEditorHidden' event and provide the Editor and annotation", ->
      spyOn(annotator, 'publish')
      annotator.onEditorHide()
      expect(annotator.publish).toHaveBeenCalledWith(
        'annotationEditorHidden', [annotator.editor]
      )

    it "should set the Annotator#ignoreMouseup property to false", ->
      annotator.ignoreMouseup = true
      annotator.onEditorHide()
      expect(annotator.ignoreMouseup).toBe(false)

  describe "onEditorSubmit", ->
    annotation = null

    beforeEach ->
      annotation = {"text": "bah"}
      spyOn(annotator, 'publish')
      spyOn(annotator, 'setupAnnotation')
      spyOn(annotator, 'updateAnnotation')

    it "should publish the 'annotationEditorSubmit' event and pass the Editor and annotation", ->
      annotator.onEditorSubmit(annotation)
      expect(annotator.publish).toHaveBeenCalledWith(
        'annotationEditorSubmit', [annotator.editor, annotation]
      )

    it "should pass the annotation to Annotator#setupAnnotation() if has no ranges", ->
      annotator.onEditorSubmit(annotation)
      expect(annotator.setupAnnotation).toHaveBeenCalledWith(annotation)

    it "should pass the annotation to Annotator#updateAnnotation() if has ranges", ->
      annotation.ranges = []
      annotator.onEditorSubmit(annotation)
      expect(annotator.updateAnnotation).toHaveBeenCalledWith(annotation)

  describe "showViewer", ->
    beforeEach ->
      spyOn(annotator, 'publish')
      spyOn(annotator.viewer, 'load')
      spyOn(annotator.viewer.element, 'css')

    it "should call Viewer#load() on the Annotator#viewer", ->
      annotations = [{text: 'my annotation comment'}]
      annotator.showViewer(annotations, {})
      expect(annotator.viewer.load).toHaveBeenCalledWith(annotations)

    it "should set the top/left properties of the Editor#element", ->
      location = {top: 20, left: 20}
      annotator.showViewer([], location)
      expect(annotator.viewer.element.css).toHaveBeenCalledWith(location)

    it "should publish the 'annotationViewerShown' event passing the viewer and annotations", ->
      annotations = [{text: 'my annotation comment'}]
      annotator.showViewer(annotations, {})
      expect(annotator.publish).toHaveBeenCalledWith(
        'annotationViewerShown', [annotator.viewer, annotations]
      )

  describe "startViewerHideTimer", ->
    beforeEach ->
      spyOn(annotator.viewer, 'hide')

    it "should call Viewer.hide() on the Annotator#viewer after 250ms", ->
      annotator.startViewerHideTimer()
      expect(annotator.viewerHideTimer).toBeTruthy()
      waits 250
      runs ->
        expect(annotator.viewer.hide).toHaveBeenCalled()

    it "should NOT call Viewer.hide() on the Annotator#viewer if @viewerHideTimer is set", ->
      annotator.viewerHideTimer = 60
      annotator.startViewerHideTimer()
      waits 250
      runs ->
        expect(annotator.viewer.hide).not.toHaveBeenCalled()

  describe "clearViewerHideTimer", ->
    it "should clear the @viewerHideTimer property", ->
      annotator.viewerHideTimer = 456
      annotator.clearViewerHideTimer()
      expect(annotator.viewerHideTimer).toBe(false)

  describe "checkForStartSelection", ->
    beforeEach ->
      spyOn(annotator, 'startViewerHideTimer')
      annotator.mouseIsDown = false
      annotator.checkForStartSelection()

    it "should call Annotator#startViewerHideTimer()", ->
      expect(annotator.startViewerHideTimer).toHaveBeenCalled()

    it "should NOT call #startViewerHideTimer() if mouse is over the annotator", ->
      annotator.startViewerHideTimer.reset()
      annotator.checkForStartSelection({target: annotator.viewer.element})
      expect(annotator.startViewerHideTimer).not.toHaveBeenCalled()

    it "should set @mouseIsDown to true", ->
      expect(annotator.mouseIsDown).toBe(true)

  describe "checkForEndSelection", ->
    mockEvent = null
    mockOffset = null
    mockRanges = null

    beforeEach ->
      mockEvent = { target: document.createElement('span') }
      mockOffset = {top: 0, left: 0}
      mockRanges = [{}]

      spyOn(util, 'mousePosition').andReturn(mockOffset)
      spyOn(annotator.adder, 'show').andReturn(annotator.adder)
      spyOn(annotator.adder, 'hide').andReturn(annotator.adder)
      spyOn(annotator.adder, 'css').andReturn(annotator.adder)
      spyOn(annotator, 'getSelectedRanges').andReturn(mockRanges)

      annotator.mouseIsDown    = true
      annotator.selectedRanges = []
      annotator.checkForEndSelection(mockEvent)

    it "should get the current selection from Annotator#getSelectedRanges()", ->
      expect(annotator.getSelectedRanges).toHaveBeenCalled()

    it "should set @mouseIsDown to false", ->
      expect(annotator.mouseIsDown).toBe(false)

    it "should set the Annotator#selectedRanges property", ->
      expect(annotator.selectedRanges).toBe(mockRanges)

    it "should display the Annotator#adder if valid selection", ->
      expect(annotator.adder.show).toHaveBeenCalled()
      expect(annotator.adder.css).toHaveBeenCalledWith(mockOffset)
      expect(util.mousePosition).toHaveBeenCalledWith(mockEvent, annotator.wrapper[0])

    it "should hide the Annotator#adder if NOT valid selection", ->
      annotator.adder.hide.reset()
      annotator.adder.show.reset()
      annotator.getSelectedRanges.andReturn([])

      annotator.checkForEndSelection(mockEvent)
      expect(annotator.adder.hide).toHaveBeenCalled()
      expect(annotator.adder.show).not.toHaveBeenCalled()

    it "should hide the Annotator#adder if target is part of the annotator", ->
      annotator.adder.hide.reset()
      annotator.adder.show.reset()

      mockNode = document.createElement('span')
      mockEvent.target = annotator.viewer.element[0]

      spyOn(annotator, 'isAnnotator').andReturn(true)
      annotator.getSelectedRanges.andReturn([{commonAncestor: mockNode}])

      annotator.checkForEndSelection(mockEvent)
      expect(annotator.isAnnotator).toHaveBeenCalledWith(mockNode)

      expect(annotator.adder.hide).not.toHaveBeenCalled()
      expect(annotator.adder.show).not.toHaveBeenCalled()

    it "should return if @ignoreMouseup is true", ->
      annotator.getSelectedRanges.reset()
      annotator.ignoreMouseup = true
      annotator.checkForEndSelection(mockEvent)
      expect(annotator.getSelectedRanges).not.toHaveBeenCalled()

  describe "isAnnotator", ->
    it "should return true if the element is part of the annotator", ->
      elements = [
        annotator.viewer.element
        annotator.adder
        annotator.editor.element.find('ul')
      ]

      for element in elements
        expect(annotator.isAnnotator(element)).toBe(true)

    it "should return false if the element is NOT part of the annotator", ->
      elements = [
        null
        annotator.element.parent()
        document.createElement('span')
        annotator.wrapper
      ]
      for element in elements
        expect(annotator.isAnnotator(element)).toBe(false)

  describe "onHighlightMouseover", ->
    element = null
    mockEvent = null
    mockOffset = null
    annotation = null

    beforeEach ->
      annotation = {text: "my comment"}
      element = $('<span />').data('annotation', annotation)
      mockEvent = {
        target: element[0]
      }
      mockOffset = {top: 0, left: 0}

      spyOn(util, 'mousePosition').andReturn(mockOffset)
      spyOn(annotator, 'showViewer')

      annotator.viewerHideTimer = 60
      annotator.onHighlightMouseover(mockEvent)

    it "should clear the current @viewerHideTimer", ->
      expect(annotator.viewerHideTimer).toBe(false)

    it "should fetch the current mouse position", ->
      expect(util.mousePosition).toHaveBeenCalledWith(mockEvent, annotator.wrapper[0])

    it "should display the Annotation#viewer with annotations", ->
      expect(annotator.showViewer).toHaveBeenCalledWith([annotation], mockOffset)

  describe "onAdderMousedown", ->
    it "should set the @ignoreMouseup property to true", ->
      annotator.ignoreMouseup = false
      annotator.onAdderMousedown()
      expect(annotator.ignoreMouseup).toBe(true)

  describe "onAdderClick", ->
    annotation = null
    mockOffset = null

    beforeEach ->
      annotation = {text: "test"}
      mockOffset = {top: 0, left:0}
      spyOn(annotator.adder, 'hide')
      spyOn(annotator.adder, 'position').andReturn(mockOffset)
      spyOn(annotator, 'createAnnotation').andReturn(annotation)
      spyOn(annotator, 'showEditor')

      annotator.onAdderClick()

    it "should hide the Annotation#adder", ->
      expect(annotator.adder.hide).toHaveBeenCalled()

    it "should create a new annotation", ->
      expect(annotator.createAnnotation).toHaveBeenCalled()

    it "should display the Annotation#editor in the same place as the Annotation#adder", ->
      expect(annotator.adder.position).toHaveBeenCalled()
      expect(annotator.showEditor).toHaveBeenCalledWith(annotation, mockOffset)

  describe "onEditAnnotation", ->
    it "should display the Annotator#editor in the same positions as Annotatorviewer", ->
      annotation = {text: "my mock annotation"}
      mockOffset = {top: 0, left: 0}

      spyOn(annotator, "showEditor")
      spyOn(annotator.viewer, "hide")
      spyOn(annotator.viewer.element, "position").andReturn(mockOffset)

      annotator.onEditAnnotation(annotation)

      expect(annotator.viewer.hide).toHaveBeenCalled()
      expect(annotator.showEditor).toHaveBeenCalledWith(annotation, mockOffset)

  describe "onDeleteAnnotation", ->
    it "should pass the annotation on to Annotator#deleteAnnotation()", ->
      annotation = {text: "my mock annotation"}
      spyOn(annotator, "deleteAnnotation")
      spyOn(annotator.viewer, "hide")

      annotator.onDeleteAnnotation(annotation)

      expect(annotator.viewer.hide).toHaveBeenCalled()
      expect(annotator.deleteAnnotation).toHaveBeenCalledWith(annotation)

describe "Annotator.noConflict()", ->
  _Annotator = null

  beforeEach ->
    _Annotator = Annotator

  afterEach ->
    window.Annotator = _Annotator

  it "should restore the value previously occupied by window.Annotator", ->
    Annotator.noConflict()
    expect(window.Annotator).not.toBeDefined()

  it "should return the Annotator object", ->
    result = Annotator.noConflict()
    expect(result).toBe(_Annotator)

describe "Annotator.supported()", ->
  it "should return true if the browser has window.getSelection method", ->
    window.getSelection = ->
    expect(Annotator.supported()).toBeTruthy()

  xit "should return false if the browser has no window.getSelection method", ->
    # The method currently checks for getSelection on load and will always
    # return that result.
    window.getSelection = undefined
    expect(Annotator.supported()).toBeFalsy()

describe "util.uuid()", ->
  it "should return a unique id on each call", ->
    counter = 100
    results = []

    while counter--
      current = util.uuid()
      expect(results.indexOf(current)).toBe(-1)
      results.push current

describe "util.preventEventDefault()", ->
  it "should call prevent default if the method exists", ->
    event = {preventDefault: jasmine.createSpy('preventDefault')}
    util.preventEventDefault(event)
    expect(event.preventDefault).toHaveBeenCalled()

    expect(-> util.preventEventDefault(1)).not.toThrow(Error)
    expect(-> util.preventEventDefault(null)).not.toThrow(Error)
    expect(-> util.preventEventDefault(undefined)).not.toThrow(Error)
