h = require('helpers')

Annotator = require('annotator')
Util = Annotator.Util
Range = Annotator.Range
$ = Util.$


describe 'Annotator', ->
  annotator = null

  beforeEach -> annotator = new Annotator($('<div></div>')[0])
  afterEach  -> $(document).unbind()

  describe "constructor", ->
    beforeEach ->
      sinon.stub(annotator, '_setupWrapper').returns(annotator)
      sinon.stub(annotator, '_setupViewer').returns(annotator)
      sinon.stub(annotator, '_setupEditor').returns(annotator)
      sinon.stub(annotator, '_setupDocumentEvents').returns(annotator)
      sinon.stub(annotator, '_setupDynamicStyle').returns(annotator)

    it 'should include the default modules', ->
      assert.isObject(annotator['annotations'], 'annotations service exists')
      assert.isObject(annotator['annotations'], 'storage service exists')

    it "should have a jQuery wrapper as @element", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      assert.instanceOf(annotator.element, $)

    it "should create an empty @plugin object", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      assert.isTrue(annotator.hasOwnProperty('plugins'))

    it "should call Annotator#_setupWrapper()", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      assert(annotator._setupWrapper.called)

    it "should call Annotator#_setupViewer()", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      assert(annotator._setupViewer.called)

    it "should call Annotator#_setupEditor()", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      assert(annotator._setupEditor.called)

    it "should call Annotator#_setupDocumentEvents()", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      assert(annotator._setupDocumentEvents.called)

    it "should NOT call Annotator#_setupDocumentEvents() if options.readOnly is true", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0], {
        readOnly: true
      })
      assert.isFalse(annotator._setupDocumentEvents.called)

    it "should call Annotator#_setupDynamicStyle()", ->
      Annotator.prototype.constructor.call(annotator, annotator.element[0])
      assert(annotator._setupDynamicStyle.called)

  describe "#destroy()", ->
    it "should remove Annotator's elements from the page", ->
      annotator.destroy()
      assert.equal(annotator.element.find('[class^=annotator-]').length, 0)

  describe "_setupViewer", ->
    mockViewer = null

    beforeEach ->
      element = $('<div />')

      mockViewer =
        fields: []
        element: element

      mockViewer.on = -> mockViewer
      mockViewer.hide = -> mockViewer
      mockViewer.addField = (options) ->
        mockViewer.fields.push options
        mockViewer

      sinon.spy(mockViewer, 'on')
      sinon.spy(mockViewer, 'hide')
      sinon.spy(mockViewer, 'addField')
      sinon.stub(element, 'bind').returns(element)
      sinon.stub(element, 'appendTo').returns(element)
      sinon.stub(Annotator, 'Viewer').returns(mockViewer)

      annotator._setupViewer()

    afterEach ->
      Annotator.Viewer.restore()

    it "should create a new instance of Annotator.Viewer and set Annotator#viewer", ->
      assert.strictEqual(annotator.viewer, mockViewer)

    it "should hide the annotator on creation", ->
      assert(mockViewer.hide.calledOnce)

    it "should setup the default text field", ->
      args = mockViewer.addField.lastCall.args[0]

      assert(mockViewer.addField.calledOnce)
      assert.equal(typeof args.load, "function")

    it "should set the contents of the field on load", ->
      field = document.createElement('div')
      annotation = {text: "test"}

      annotator.viewer.fields[0].load(field, annotation)
      assert.equal($(field).html(), "test")

    it "should set the contents of the field to placeholder text when empty", ->
      field = document.createElement('div')
      annotation = {text: ""}

      annotator.viewer.fields[0].load(field, annotation)
      assert.equal($(field).html(), "<i>No Comment</i>")

    it "should setup the default text field to publish an event on load", ->
      field = document.createElement('div')
      annotation = {text: "test"}
      callback = sinon.spy()

      annotator.on('annotationViewerTextField', callback)
      annotator.viewer.fields[0].load(field, annotation)
      assert(callback.calledWith(field, annotation))

    it "should subscribe to custom events", ->
      assert.equal('edit', mockViewer.on.args[0][0])
      assert.equal('delete', mockViewer.on.args[1][0])

    it "should bind to browser mouseover and mouseout events", ->
      assert(mockViewer.element.bind.calledWith({
        'mouseover': annotator.clearViewerHideTimer
        'mouseout':  annotator.startViewerHideTimer
      }))

    it "should append the Viewer#element to the Annotator#wrapper", ->
      assert(mockViewer.element.appendTo.calledWith(annotator.wrapper))

  describe "_setupEditor", ->
    mockEditor = null

    beforeEach ->
      element = $('<div />')

      mockEditor = {
        element: element
      }
      mockEditor.on = -> mockEditor
      mockEditor.hide = -> mockEditor
      mockEditor.addField = -> document.createElement('li')

      sinon.spy(mockEditor, 'on')
      sinon.spy(mockEditor, 'hide')
      sinon.spy(mockEditor, 'addField')
      sinon.stub(element, 'appendTo').returns(element)
      sinon.stub(Annotator, 'Editor').returns(mockEditor)

      annotator._setupEditor()

    afterEach ->
      Annotator.Editor.restore()

    it "should create a new instance of Annotator.Editor and set Annotator#editor", ->
      assert.strictEqual(annotator.editor, mockEditor)

    it "should hide the annotator on creation", ->
      assert(mockEditor.hide.calledOnce)

    it "should add the default textarea field", ->
      options = mockEditor.addField.lastCall.args[0]

      assert(mockEditor.addField.calledOnce)
      assert.equal(options.type, 'textarea')
      assert.equal(options.label, 'Comments\u2026')
      assert.typeOf(options.load, 'function')
      assert.typeOf(options.submit, 'function')

    it "should subscribe to custom events", ->
      assert(mockEditor.on.calledWith('hide', annotator.onEditorHide))
      assert(mockEditor.on.calledWith('save', annotator.onEditorSubmit))

    it "should append the Editor#element to the Annotator#wrapper", ->
      assert(mockEditor.element.appendTo.calledWith(annotator.wrapper))

  describe "_setupDynamicStyle", ->
    $fix = null

    beforeEach ->
      h.addFixture 'annotator'
      $fix = $(h.fix())

    afterEach -> h.clearFixtures()

    it 'should ensure Annotator z-indices are larger than others in the page', ->
      $fix.show()

      $adder = $('<div style="position:relative;" class="annotator-adder">&nbsp;</div>').appendTo($fix)
      $filter = $('<div style="position:relative;" class="annotator-filter">&nbsp;</div>').appendTo($fix)

      check = (minimum) ->
        adderZ = parseInt($adder.css('z-index'), 10)
        filterZ = parseInt($filter.css('z-index'), 10)
        assert.isTrue(adderZ > minimum)
        assert.isTrue(filterZ > minimum)
        assert.isTrue(adderZ > filterZ)

      check(1000)

      $fix.append('<div style="position: relative; z-index: 2000"></div>')
      annotator._setupDynamicStyle()
      check(2000)

      $fix.append('<div style="position: relative; z-index: 10000"></div>')
      annotator._setupDynamicStyle()
      check(10000)

      $fix.hide()

  describe "setupAnnotation", ->
    annotation = null
    quote = null
    comment = null
    element = null
    annotationObj = null
    normalizedRange = null
    sniffedRange = null

    beforeEach ->
      quote   = 'This is some annotated text'
      comment = 'This is a comment on an annotation'
      element = $('<span />')

      normalizedRange = {
        text: sinon.stub().returns(quote)
        serialize: sinon.stub().returns({})
      }
      sniffedRange = {
        normalize: sinon.stub().returns(normalizedRange)
      }
      sinon.stub(Range, 'sniff').returns(sniffedRange)
      sinon.spy(annotator, 'publish')

      annotationObj = {
        text: comment,
        ranges: [1]
      }
      annotation = annotator.setupAnnotation(annotationObj)

    afterEach ->
      Range.sniff.restore()

    it "should return the annotation object with a comment", ->
      assert.equal(annotation.text, comment)

    it "should return the annotation object with the quoted text", ->
      assert.equal(annotation.quote, quote)

    it "should trim whitespace from start and end of quote", ->
      normalizedRange.text.returns('\n\t   ' + quote + '   \n')
      annotation = annotator.setupAnnotation(annotationObj)
      assert.equal(annotation.quote, quote)

    it "should set the annotation.ranges", ->
      assert.deepEqual(annotation.ranges, [{}])

    it "should exclude any ranges that could not be normalized", ->
      e = new Range.RangeError("typ", "msg")
      sniffedRange.normalize.throws(e)
      annotation = annotator.setupAnnotation({
        text: comment,
        ranges: [1]
      })

      assert.deepEqual(annotation.ranges, [])

    it "should trigger rangeNormalizeFail for each range that can't be normalized", ->
      e = new Range.RangeError("typ", "msg")
      sniffedRange.normalize.throws(e)
      annotator.publish = sinon.spy()
      annotation = annotator.setupAnnotation({
        text: comment,
        ranges: [1]
      })

      assert.isTrue(annotator.publish.calledWith('rangeNormalizeFail', [annotation, 1, e]))

  describe "loadAnnotations", ->
    beforeEach ->
      sinon.stub(annotator, 'setupAnnotation')
      sinon.spy(annotator, 'publish')

    it "should call Annotator#setupAnnotation for each annotation in the Array", ->
      annotations = [{}, {}, {}, {}]
      annotator.loadAnnotations(annotations)
      assert.equal(annotator.setupAnnotation.callCount, 4)

    it "should publish the annotationsLoaded event with all loaded annotations", ->
      annotations = [{}, {}, {}, {}]
      annotator.loadAnnotations(annotations.slice())
      assert.isTrue(annotator.publish.calledWith('annotationsLoaded', [annotations]))

    it "should break the annotations into blocks of 10", ->
      clock = sinon.useFakeTimers()
      annotations = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]

      annotator.loadAnnotations(annotations)
      assert.equal(annotator.setupAnnotation.callCount, 10)

      while annotations.length > 0
        clock.tick(10)

      assert.equal(annotator.setupAnnotation.callCount, 13)
      clock.restore()

  describe "dumpAnnotations", ->
    it "returns false and prints a warning if no Store plugin is active", ->
      sinon.stub(console, 'warn')
      assert.isFalse(annotator.dumpAnnotations())
      assert(console.warn.calledOnce)

    it "returns the results of the Store plugins dumpAnnotations method", ->
      annotator.store = { dumpAnnotations: -> [1,2,3] }
      assert.deepEqual(annotator.dumpAnnotations(), [1,2,3])

  describe "addPlugin", ->
    plugin = null
    Foo = null

    beforeEach ->
      plugin = {
        pluginInit: sinon.spy()
      }
      Foo = sinon.stub().returns(plugin)
      Annotator.Plugin.register('Foo', Foo)

    it "should add and instantiate a plugin of the specified name", ->
      annotator.addPlugin('Foo')
      assert.isTrue(Foo.calledWith(annotator.element[0], undefined))

    it "should pass on the provided options", ->
      options = {foo: 'bar'}
      annotator.addPlugin('Foo', options)
      assert.isTrue(Foo.calledWith(annotator.element[0], options))

    it "should attach the Annotator instance", ->
      annotator.addPlugin('Foo')
      assert.equal(plugin.annotator, annotator)

    it "should call Plugin#pluginInit()", ->
      annotator.addPlugin('Foo')
      assert(plugin.pluginInit.calledOnce)

    it "should complain if you try and instantiate a plugin that doesn't exist", ->
      sinon.stub(console, 'error')
      annotator.addPlugin('Bar')
      assert.isFalse(annotator.plugins['Bar']?)
      assert(console.error.calledOnce)
      console.error.restore()

  describe "showEditor", ->
    beforeEach ->
      sinon.spy(annotator, 'publish')
      sinon.spy(annotator.editor, 'load')
      sinon.spy(annotator.editor.element, 'css')

    it "should call Editor#load() on the Annotator#editor", ->
      annotation = {text: 'my annotation comment'}
      annotator.showEditor(annotation, {})
      assert.isTrue(annotator.editor.load.calledWith(annotation))

    it "should set the top/left properties of the Editor#element", ->
      location = {top: 20, left: 20}
      annotator.showEditor({}, location)
      assert.isTrue(annotator.editor.element.css.calledWith(location))

    it "should publish the 'annotationEditorShown' event passing the editor and annotations", ->
      annotation = {text: 'my annotation comment'}
      annotator.showEditor(annotation, {})
      assert(annotator.publish.calledWith('annotationEditorShown', [annotator.editor, annotation]))

  describe "onEditorHide", ->
    it "should publish the 'annotationEditorHidden' event and provide the Editor and annotation", ->
      sinon.spy(annotator, 'publish')
      annotator.onEditorHide()
      assert(annotator.publish.calledWith('annotationEditorHidden', [annotator.editor]))

    it "should set the Annotator#ignoreMouseup property to false", ->
      annotator.ignoreMouseup = true
      annotator.onEditorHide()
      assert.isFalse(annotator.ignoreMouseup)

  describe "onEditorSubmit", ->
    annotation = null

    beforeEach ->
      annotation = {"text": "bah"}
      sinon.spy(annotator, 'publish')
      sinon.spy(annotator, 'setupAnnotation')

    it "should publish the 'annotationEditorSubmit' event and pass the Editor and annotation", ->
      annotator.onEditorSubmit(annotation)
      assert(annotator.publish.calledWith('annotationEditorSubmit', [annotator.editor, annotation]))

  describe "showViewer", ->
    beforeEach ->
      sinon.spy(annotator, 'publish')
      sinon.spy(annotator.viewer, 'load')
      sinon.spy(annotator.viewer.element, 'css')

    it "should call Viewer#load() on the Annotator#viewer", ->
      annotations = [{text: 'my annotation comment'}]
      annotator.showViewer(annotations, {})
      assert.isTrue(annotator.viewer.load.calledWith(annotations))

    it "should set the top/left properties of the Editor#element", ->
      location = {top: 20, left: 20}
      annotator.showViewer([], location)
      assert.isTrue(annotator.viewer.element.css.calledWith(location))

    it "should publish the 'annotationViewerShown' event passing the viewer and annotations", ->
      annotations = [{text: 'my annotation comment'}]
      annotator.showViewer(annotations, {})
      assert(annotator.publish.calledWith('annotationViewerShown', [annotator.viewer, annotations]))

  describe "startViewerHideTimer", ->
    beforeEach ->
      sinon.spy(annotator.viewer, 'hide')

    it "should call Viewer.hide() on the Annotator#viewer after 250ms", ->
      clock = sinon.useFakeTimers()
      annotator.startViewerHideTimer()
      clock.tick(250)
      assert(annotator.viewer.hide.calledOnce)
      clock.restore()

    it "should NOT call Viewer.hide() on the Annotator#viewer if @viewerHideTimer is set", ->
      clock = sinon.useFakeTimers()
      annotator.viewerHideTimer = 60
      annotator.startViewerHideTimer()
      clock.tick(250)
      assert.isFalse(annotator.viewer.hide.calledOnce)
      clock.restore()

  describe "clearViewerHideTimer", ->
    it "should clear the @viewerHideTimer property", ->
      annotator.viewerHideTimer = 456
      annotator.clearViewerHideTimer()
      assert.isFalse(annotator.viewerHideTimer)

  describe "onEditAnnotation", ->
    annotation = null
    mockOffset = null
    mockSubscriber = null

    beforeEach ->
      annotation = {id: 123, text: "my mock annotation"}
      mockOffset = {top: 0, left: 0}
      mockSubscriber = sinon.spy()
      sinon.spy(annotator, "showEditor")
      sinon.spy(annotator.annotations, "update")
      sinon.spy(annotator.viewer, "hide")
      sinon.stub(annotator.viewer.element, "position").returns(mockOffset)
      annotator.onEditAnnotation(annotation)

    it "should hide the viewer", ->
      assert(annotator.viewer.hide.calledOnce)

    it "should show the editor", ->
      assert(annotator.showEditor.calledOnce)

    it "should update the annotation if the edit is saved", ->
      annotator.onEditorSubmit(annotation)
      assert(annotator.annotations.update.calledWith(annotation))

    it "should not update the annotation if editing is cancelled", ->
      do annotator.onEditorHide
      annotator.onEditorSubmit(annotation)
      assert.isFalse(annotator.annotations.update.calledWith(annotation))


describe 'Annotator.Factory', ->
  it "should use Annotator as the default core constructor", ->
    factory = new Annotator.Factory()
    a = factory.getInstance()
    assert.instanceOf(a, Annotator)


describe "Annotator.noConflict()", ->
  _Annotator = null

  beforeEach ->
    _Annotator = Annotator

  afterEach ->
    window.Annotator = _Annotator

  it "should restore the value previously occupied by window.Annotator", ->
    Annotator.noConflict()
    assert.isUndefined(window.Annotator)

  it "should return the Annotator object", ->
    result = Annotator.noConflict()
    assert.equal(result, _Annotator)

describe "Annotator.supported()", ->

  beforeEach ->
    window._Selection = window.getSelection

  afterEach ->
    window.getSelection = window._Selection

  it "should return true if the browser has window.getSelection method", ->
    window.getSelection = ->
    assert.isTrue(Annotator.supported())

  xit "should return false if the browser has no window.getSelection method", ->
    # The method currently checks for getSelection on load and will always
    # return that result.
    window.getSelection = undefined
    assert.isFalse(Annotator.supported())
