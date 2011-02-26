describe 'Annotator.Plugin.Tags', ->
  annotator = null
  plugin = null

  beforeEach ->
    el = $("<div><div class='annotator-editor-controls'></div></div>")[0]
    annotator = new Annotator($('<div/>')[0])
    plugin = new Annotator.Plugin.Tags(el)
    plugin.annotator = annotator
    plugin.pluginInit()

  it "should parse whitespace-delimited tags into an array", ->
    str = 'one two  three\tfourFive'
    expect(plugin.parseTags(str)).toEqual(['one', 'two', 'three', 'fourFive'])

  it "should stringify a tags array into a space-delimited string", ->
    ary = ['one', 'two', 'three']
    expect(plugin.stringifyTags(ary)).toEqual("one two three")

  describe "pluginInit", ->
    it "should add a field to the editor", ->
      spyOn(annotator.editor, 'addField')
      plugin.pluginInit()
      expect(annotator.editor.addField).toHaveBeenCalled()

  describe "updateField", ->
    it "should set the value of the input", ->
      annotation = {tags: ['apples', 'oranges', 'pears']}
      plugin.updateField(plugin.field, annotation)

      expect(plugin.input.val()).toEqual('apples oranges pears')

    it "should set the clear the value of the input if there are no tags", ->
      annotation = {}
      plugin.input.val('apples pears oranges')
      plugin.updateField(plugin.field, annotation)

      expect(plugin.input.val()).toEqual('')

  describe "setAnnotationTags", ->
    it "should set the annotation's tags", ->
      annotation = {}
      plugin.input.val('apples oranges pears')
      plugin.setAnnotationTags(plugin.field, annotation)

      expect(annotation.tags).toEqual(['apples', 'oranges', 'pears'])

  it "should show the tags on annotationViewerShown", ->
    annotations = [{ tags: ['foo', 'bar', 'baz'] }]
    viewerEl = $("<div><div class='annotator-ann'><div class='annotator-ann-text'></div></div></div>")[0]
    $(plugin.element).trigger('annotationViewerShown', [viewerEl, annotations])
    tags = $(viewerEl).find('.annotator-ann-tags')
    expect(tags.text()).toEqual('foo, bar, baz')
