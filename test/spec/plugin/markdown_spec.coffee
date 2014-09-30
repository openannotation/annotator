Annotator = require('annotator')
Markdown = require('../../../src/plugin/markdown')
$ = Annotator.Util.$


describe 'Markdown plugin', ->
  input  = 'Is **this** [Markdown](http://daringfireball.com)?'
  output = '<p>Is <strong>this</strong> <a href="http://daringfireball.com">Markdown</a>?</p>'
  annotator = null
  plugin = null

  beforeEach ->
    plugin = new Markdown($('<div/>')[0])

    sinon.spy(Markdown::, 'updateTextField')
    plugin.pluginInit()

  afterEach ->
    Markdown::updateTextField.restore()
    plugin.destroy()

  describe "#updateTextField()", ->
    it "should be called when annotationViewerTextField event is fired", ->
      field = $('<div />')[0]
      annotation = {text: 'test'}
      annotator.trigger('annotationViewerTextField', field, annotation)
      assert.isTrue(plugin.updateTextField.calledWith(field, annotation))

  describe "constructor", ->
    it "should create a new instance of Showdown", ->
      assert.ok(plugin.converter)

    it "should log an error if Showdown is not loaded", ->
      sinon.stub(console, 'error')

      converter = Showdown.converter
      Showdown.converter = null

      plugin = new Markdown($('<div />')[0])
      assert(console.error.calledOnce)

      Showdown.converter = converter
      console.error.restore()

  describe "updateTextField", ->
    field      = null
    annotation = null

    beforeEach ->
      field = $('<div />')[0]
      annotation = {text: input}
      sinon.stub(plugin, 'convert').returns(output)
      sinon.stub(Annotator.Util, 'escape').returns(input)

      plugin.updateTextField(field, annotation)

    afterEach ->
      Annotator.Util.escape.restore()

    it 'should process the annotation text as Markdown', ->
      assert.isTrue(plugin.convert.calledWith(input))

    it 'should update the content in the field', ->
      # In IE, tags might be converted into all uppercase,
      # so we need to normalize those.
      assert.equal($(field).html().toLowerCase(), output.toLowerCase())

      # But also make sure the text is exactly the same.
      assert.equal($(field).text(), $(output).text())

    it "should escape any existing HTML to prevent XSS", ->
      assert.isTrue(Annotator.Util.escape.calledWith(input))

  describe "convert", ->
    it "should convert the provided text into markdown", ->
      assert.equal(plugin.convert(input), output)
