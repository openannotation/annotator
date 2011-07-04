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

    it "should register a filter if the Filter plugin is loaded", ->
      plugin.annotator.plugins.Filter = {addFilter: jasmine.createSpy()}
      plugin.pluginInit()
      expect(plugin.annotator.plugins.Filter.addFilter).toHaveBeenCalled()

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

  describe "updateViewer", ->
    it "should insert the tags into the field", ->
      annotation = { tags: ['foo', 'bar', 'baz'] }
      field = $('<div />')[0]

      plugin.updateViewer(field, annotation)
      expect($(field).html()).toEqual([
        '<span class="annotator-tag">foo</span>'
        '<span class="annotator-tag">bar</span>'
        '<span class="annotator-tag">baz</span>'
      ].join(' '))

    it "should remove the field if there are no tags", ->
      annotation = { tags: [] }
      field = $('<div />')[0]

      plugin.updateViewer(field, annotation)
      expect($(field).parent().length).toEqual(0)

      annotation = {}
      field = $('<div />')[0]

      plugin.updateViewer(field, annotation)
      expect($(field).parent().length).toEqual(0)


describe 'Annotator.Plugin.Tags.filterCallback', ->
  filter = null
  beforeEach -> filter = Annotator.Plugin.Tags.filterCallback

  it 'should return true if all tags are matched by keywords', ->
    expect(filter('cat dog mouse', ['cat', 'dog', 'mouse'])).toBe(true)
    expect(filter('cat dog', ['cat', 'dog', 'mouse'])).toBe(true)

  it 'should NOT return true if all tags are NOT matched by keywords', ->
    expect(filter('cat dog', ['cat'])).toBe(false)
    expect(filter('cat dog', [])).toBe(false)
