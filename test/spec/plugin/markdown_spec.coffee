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

      spyOn(plugin, 'updateTextField')
      plugin.publish('annotationViewerTextField', [field, annotation])
      expect(plugin.updateTextField).toHaveBeenCalledWith(field, annotation)

  describe "constructor", ->
    it "should create a new instance of Showdown", ->
      expect(plugin.converter).toBeTruthy()

    it "should log an error if Showdown is not loaded", ->
      spyOn(console, 'error')

      converter = Showdown.converter
      Showdown.converter = null

      plugin = new Annotator.Plugin.Markdown($('<div />')[0])
      expect(console.error).toHaveBeenCalled()
      
      Showdown.converter = converter

  describe "updateTextField", ->
    field      = null
    annotation = null

    beforeEach ->
      field = $('<div />')[0]
      annotation = {text: input}
      spyOn(plugin, 'convert').andReturn(output)
      spyOn(Annotator.$, 'escape').andReturn(input)
      
      plugin.updateTextField(field, annotation)

    it 'should process the annotation text as Markdown', ->
      expect(plugin.convert).toHaveBeenCalledWith(input)

    it 'should update the content in the field', ->
      expect($(field).html()).toBe(output)

    it "should escape any existing HTML to prevent XSS", ->
      expect(Annotator.$.escape).toHaveBeenCalledWith(input)

  describe "convert", ->
    it "should convert the provided text into markdown", ->
      expect(plugin.convert(input)).toBe(output)
