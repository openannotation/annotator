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
    assert.deepEqual(plugin.parseTags(str), ['one', 'two', 'three', 'fourFive'])

  it "should stringify a tags array into a space-delimited string", ->
    ary = ['one', 'two', 'three']
    assert.equal(plugin.stringifyTags(ary), "one two three")

  describe "pluginInit", ->
    it "should add a field to the editor", ->
      sinon.spy(annotator.editor, 'addField')
      plugin.pluginInit()
      assert(annotator.editor.addField.calledOnce)

    it "should register a filter if the Filter plugin is loaded", ->
      plugin.annotator.plugins.Filter = {addFilter: sinon.spy()}
      plugin.pluginInit()
      assert(plugin.annotator.plugins.Filter.addFilter.calledOnce)

  describe "updateField", ->
    it "should set the value of the input", ->
      annotation = {tags: ['apples', 'oranges', 'pears']}
      plugin.updateField(plugin.field, annotation)

      assert.equal(plugin.input.val(), 'apples oranges pears')

    it "should set the clear the value of the input if there are no tags", ->
      annotation = {}
      plugin.input.val('apples pears oranges')
      plugin.updateField(plugin.field, annotation)

      assert.equal(plugin.input.val(), '')

  describe "setAnnotationTags", ->
    it "should set the annotation's tags", ->
      annotation = {}
      plugin.input.val('apples oranges pears')
      plugin.setAnnotationTags(plugin.field, annotation)

      assert.deepEqual(annotation.tags, ['apples', 'oranges', 'pears'])

  describe "updateViewer", ->
    it "should insert the tags into the field", ->
      annotation = { tags: ['foo', 'bar', 'baz'] }
      field = $('<div />')[0]

      plugin.updateViewer(field, annotation)
      assert.deepEqual($(field).html(), [
        '<span class="annotator-tag">foo</span>'
        '<span class="annotator-tag">bar</span>'
        '<span class="annotator-tag">baz</span>'
      ].join(' '))

    it "should remove the field if there are no tags", ->
      annotation = { tags: [] }
      field = $('<div />')[0]

      plugin.updateViewer(field, annotation)
      assert.lengthOf($(field).parent(), 0)

      annotation = {}
      field = $('<div />')[0]

      plugin.updateViewer(field, annotation)
      assert.lengthOf($(field).parent(), 0)


describe 'Annotator.Plugin.Tags.filterCallback', ->
  filter = null
  beforeEach -> filter = Annotator.Plugin.Tags.filterCallback

  it 'should return true if all tags are matched by keywords', ->
    assert.isTrue(filter('cat dog mouse', ['cat', 'dog', 'mouse']))
    assert.isTrue(filter('cat dog', ['cat', 'dog', 'mouse']))

  it 'should NOT return true if all tags are NOT matched by keywords', ->
    assert.isFalse(filter('cat dog', ['cat']))
    assert.isFalse(filter('cat dog', []))
