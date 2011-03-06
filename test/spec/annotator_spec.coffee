describe 'Annotator', ->
  annotator = null

  beforeEach ->
    annotator = new Annotator($('<div></div>')[0], {})

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

    it "should call Annotator#checkForStartSelection() when mouse button is pressed inside element", ->
      spyOn(annotator, 'checkForStartSelection')
      annotator.element.mousedown()
      expect(annotator.checkForStartSelection).toHaveBeenCalled()

    it "should call Annotator#checkForEndSelection() when mouse button is lifted inside element", ->
      spyOn(annotator, 'checkForEndSelection')
      annotator.element.mouseup()
      expect(annotator.checkForEndSelection).toHaveBeenCalled()

  describe "constructor", ->
    beforeEach ->
      spyOn(annotator, '_setupWrapper').andReturn(annotator)
      spyOn(annotator, '_setupViewer').andReturn(annotator)
      spyOn(annotator, '_setupEditor').andReturn(annotator)
      Annotator.prototype.constructor.call(annotator, annotator.element[0])

    it "should have a jQuery wrapper as @element", ->
      expect(annotator.element instanceof $).toBeTruthy()

    it "should create an empty @plugin object", ->
      expect(annotator.hasOwnProperty('plugins')).toBeTruthy()

    it "should create the adder and highlight properties from the @html strings", ->
      expect(annotator.adder instanceof $).toBeTruthy()
      expect(annotator.hl instanceof $).toBeTruthy()

    it "should call Annotator#_setupWrapper()", ->
      expect(annotator._setupWrapper).toHaveBeenCalled()

    it "should call Annotator#_setupViewer()", ->
      expect(annotator._setupViewer).toHaveBeenCalled()

    it "should call Annotator#_setupEditor()", ->
      expect(annotator._setupEditor).toHaveBeenCalled()

  describe "_setupWrapper", ->
    it "should wrap children of @element in the @html.wrapper element", ->
      annotator.element = $('<div />')
      annotator._setupWrapper()
      expect(annotator.element.html()).toBe(annotator.html.wrapper)

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
        element: element
        hide: jasmine.createSpy('Viewer#hide()')
        on: jasmine.createSpy('Viewer#on()')
      }
      mockViewer.on.andReturn(mockViewer)
      mockViewer.hide.andReturn(mockViewer)

      spyOn(element, 'bind').andReturn(element)
      spyOn(element, 'appendTo').andReturn(element)
      spyOn(Annotator, 'Viewer').andReturn(mockViewer)

    it "should create a new instance of Annotator.Viewer and set Annotator#viewer", ->
      annotator._setupViewer()
      expect(annotator.viewer).toBe(mockViewer)

    it "should hide the annotator on creation", ->
      annotator._setupViewer()
      expect(mockViewer.hide).toHaveBeenCalled()

    it "should subscribe to custom events", ->
      annotator._setupViewer()
      expect(mockViewer.on).toHaveBeenCalledWith('edit', annotator.onEditAnnotation)
      expect(mockViewer.on).toHaveBeenCalledWith('delete', annotator.onDeleteAnnotation)

    it "should bind to browser mouseover and mouseout events", ->
      annotator._setupViewer()
      expect(mockViewer.element.bind).toHaveBeenCalledWith({
        'mouseover': annotator.clearViewerHideTimer
        'mouseout':  annotator.startViewerHideTimer
      })

    it "should append the Viewer#element to the Annotator#wrapper", ->
      annotator._setupViewer()
      expect(mockViewer.element.appendTo).toHaveBeenCalledWith(annotator.wrapper)

  describe "_setupEditor", ->
    mockEditor = null

    beforeEach ->
      element = $('<div />')

      mockEditor = {
        element: element
        hide: jasmine.createSpy('Editor#hide()')
        on: jasmine.createSpy('Editor#on()')
      }
      mockEditor.on.andReturn(mockEditor)
      mockEditor.hide.andReturn(mockEditor)

      spyOn(element, 'appendTo').andReturn(element)
      spyOn(Annotator, 'Editor').andReturn(mockEditor)

    it "should create a new instance of Annotator.Editor and set Annotator#editor", ->
      annotator._setupEditor()
      expect(annotator.editor).toBe(mockEditor)

    it "should hide the annotator on creation", ->
      annotator._setupEditor()
      expect(mockEditor.hide).toHaveBeenCalled()

    it "should subscribe to custom events", ->
      annotator._setupEditor()
      expect(mockEditor.on).toHaveBeenCalledWith('hide', annotator.onEditorHide)
      expect(mockEditor.on).toHaveBeenCalledWith('save', annotator.onEditorSubmit)

    it "should append the Editor#element to the Annotator#wrapper", ->
      annotator._setupEditor()
      expect(mockEditor.element.appendTo).toHaveBeenCalledWith(annotator.wrapper)

  describe "getSelection", ->
    mockGlobal = null
    mockSelection = null

    beforeEach ->
      mockSelection = {
        getRangeAt: jasmine.createSpy().andReturn('')
        rangeCount: 1
      }
      mockGlobal = {
        getSelection: jasmine.createSpy().andReturn(mockSelection)
      }
      spyOn(util, 'getGlobal').andReturn(mockGlobal)

    it "should retrieve the global object and call getSelection()", ->
      annotator.getSelection()
      expect(mockGlobal.getSelection).toHaveBeenCalled()

    it "should retrieve the global object and call getSelection()", ->
      selection = annotator.getSelection()
      expect(selection).toBe(mockSelection)

    it "should set Annotator#selection", ->
      annotator.getSelection()
      expect(annotator.selection).toBe(mockSelection)

    it "should iterate over selected ranges and set Annotator#selectedRanges", ->
      annotator.getSelection()
      expect(annotator.selectedRanges).toEqual([''])

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
        ranges: [1, 2]
      }
      annotation = annotator.setupAnnotation(annotationObj)

    it "should return the annotation object with a comment", ->
      expect(annotation.text).toEqual(comment)

    it "should return the annotation object with the quoted text", ->
      expect(annotation.quote).toEqual(quote)

    it "should set the annotation.ranges", ->
      expect(annotation.ranges).toEqual([{}, {}])

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

    it "should call Annotator#setupAnnotation for each annotation in the Array", ->
      annotations = [{}, {}, {}, {}]
      annotator.loadAnnotations(annotations)
      expect(annotator.setupAnnotation.callCount).toBe(4)

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
      textNodes = for text in ['hello', 'world']
        node = document.createTextNode()
        node.nodeValue = text
        node
      mockRange = {
        textNodes: -> textNodes
      }
      elements = annotator.highlightRange(mockRange)

      expect(elements.length).toBe(2)
      expect(elements[0].className).toBe('annotator-hl')
      expect(elements[0].firstChild).toBe(textNodes[0])
      expect(elements[1].firstChild).toBe(textNodes[1])

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

  describe "checkForEndSelection", ->
    it "loads selections from the window object on checkForEndSelection", ->
      if /Node\.js/.test(navigator.userAgent)
        expectation = "Node selection"
      else
        expectation = "Text selection"
        spyOn(window, 'getSelection').andReturn(expectation)

      annotator.checkForEndSelection()
      expect(annotator.selection).toEqual(expectation)

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
