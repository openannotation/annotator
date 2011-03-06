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

  describe "checkForEndSelection", ->
    it "loads selections from the window object on checkForEndSelection", ->
      if /Node\.js/.test(navigator.userAgent)
        expectation = "Node selection"
      else
        expectation = "Text selection"
        spyOn(window, 'getSelection').andReturn(expectation)

      annotator.checkForEndSelection()
      expect(annotator.selection).toEqual(expectation)

  describe "createAnnotation", ->
    annotation = null
    quote = null
    comment = null

    beforeEach ->
      quote = 'This is some annotated text'
      comment = 'This is a comment on an annotation'

      # Create our quoted text.
      paragraph = document.createElement('p')
      node = document.createTextNode()
      node.nodeValue = quote
      paragraph.appendChild(node)

      annotationObj = {
        text: comment,
        ranges: [new Range.NormalizedRange({
          commonAncestor: paragraph,
          start: node,
          end: node
        })]
      }
      annotation = annotator.createAnnotation(annotationObj)

    it "should return the annotation object with a comment", ->
      expect(annotation.text).toEqual(comment)

    it "should return the annotation object with the quoted text", ->
      expect(annotation.quote).toEqual(quote)

  describe "dumpAnnotations", ->
    it "returns false and prints a warning if no Store plugin is active", ->
      spyOn(console, 'warn')
      expect(annotator.dumpAnnotations()).toBeFalsy()
      expect(console.warn).toHaveBeenCalled()

    it "returns the results of the Store plugins dumpAnnotations method", ->
      annotator.plugins.Store = { dumpAnnotations: -> [1,2,3] }
      expect(annotator.dumpAnnotations()).toEqual([1,2,3])

  describe "addPlugin", ->

    Annotator.Plugin.Foo = -> this.name = "Bar"

    it "should add and instantiate a plugin of the specified name", ->
      annotator.addPlugin('Foo')
      expect(annotator.plugins['Foo'].name).toEqual('Bar')

    it "should complain if you try and instantiate a plugin twice", ->
      spyOn(console, 'error')
      annotator.addPlugin('Foo')
      annotator.addPlugin('Foo')
      expect(annotator.plugins['Foo'].name).toEqual('Bar')
      expect(console.error).toHaveBeenCalled()

    it "should complain if you try and instantiate a plugin that doesn't exist", ->
      spyOn(console, 'error')
      annotator.addPlugin('Bar')
      expect(annotator.plugins['Bar']?).toBeFalsy()
      expect(console.error).toHaveBeenCalled()

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
