describe 'Annotator.Plugin.Markdown', ->
  input  = 'Is **this** [Markdown](http://daringfireball.com)?'
  output = '<p>Is <strong>this</strong> <a href="http://daringfireball.com">Markdown</a>?</p>'
  plugin = null


  beforeEach ->
    plugin = new Annotator.Plugin.Markdown($('<div />')[0])

  describe "events", ->
    it "should call Markdown#updateTextField() when annotationViewerTextField event is fired", ->
      field = $('<div />')[0]
      annotation = {text: 'test'}

      sinon.spy(plugin, 'updateTextField')
      plugin.publish('annotationViewerTextField', [field, annotation])
      assert.isTrue(plugin.updateTextField.calledWith(field, annotation))

  describe "constructor", ->
    it "should create a new instance of Showdown", ->
      assert.ok(plugin.converter)

    it "should log an error if Showdown is not loaded", ->
      sinon.stub(console, 'error')

      converter = Showdown.converter
      Showdown.converter = null

      plugin = new Annotator.Plugin.Markdown($('<div />')[0])
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
      assert.equal($(field).html(), output)

    it "should escape any existing HTML to prevent XSS", ->
      assert.isTrue(Annotator.Util.escape.calledWith(input))

  describe "convert", ->
    it "should convert the provided text into markdown", ->
      assert.equal(plugin.convert(input), output)
