describe 'Annotator', ->
  a = null

  beforeEach ->
    a = new Annotator($('<div></div>')[0], {})

  it "loads selections from the window object on checkForSelection", ->
    if /Node\.js/.test(navigator.userAgent)
      expectation = "Node selection"
    else
      expectation = "Text selection"
      spyOn(window, 'getSelection').andReturn(expectation)

    a.checkForEndSelection()
    expect(a.selection).toEqual(expectation)

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
      annotation = a.createAnnotation(annotationObj)

    it "should return the annotation object with a comment", ->
      expect(annotation.text).toEqual(comment)

    it "should return the annotation object with the quoted text", ->
      expect(annotation.quote).toEqual(quote)

  describe "dumpAnnotations", ->
    it "returns false and prints a warning if no Store plugin is active", ->
      spyOn(console, 'warn')
      expect(a.dumpAnnotations()).toBeFalsy()
      expect(console.warn).toHaveBeenCalled()

    it "returns the results of the Store plugins dumpAnnotations method", ->
      a.plugins.Store = { dumpAnnotations: -> [1,2,3] }
      expect(a.dumpAnnotations()).toEqual([1,2,3])

  describe "addPlugin", ->

    Annotator.Plugin.Foo = -> this.name = "Bar"

    it "should add and instantiate a plugin of the specified name", ->
      a.addPlugin('Foo')
      expect(a.plugins['Foo'].name).toEqual('Bar')

    it "should complain if you try and instantiate a plugin twice", ->
      spyOn(console, 'error')
      a.addPlugin('Foo')
      a.addPlugin('Foo')
      expect(a.plugins['Foo'].name).toEqual('Bar')
      expect(console.error).toHaveBeenCalled()

    it "should complain if you try and instantiate a plugin that doesn't exist", ->
      spyOn(console, 'error')
      a.addPlugin('Bar')
      expect(a.plugins['Bar']?).toBeFalsy()
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
