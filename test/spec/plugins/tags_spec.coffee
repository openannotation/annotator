describe 'Annotator.Plugin.Tags', ->
  t = null

  beforeEach ->
    el = $("<div><div class='annotator-editor-controls'></div></div>")[0]
    t = new Annotator.Plugins.Tags(el)

  it "should parse whitespace-delimited tags into an array", ->
    str = 'one two  three\tfourFive'
    expect(t.parseTags(str)).toEqual(['one', 'two', 'three', 'fourFive'])

  it "should stringify a tags array into a space-delimited string", ->
    ary = ['one', 'two', 'three']
    expect(t.stringifyTags(ary)).toEqual("one two three")

  it "should insert an input element for tags on annotationEditorShown", ->
    $(t.element).trigger('annotationEditorShown', [t.element])
    tags = $(t.element).find('input.annotator-editor-tags')
    expect(tags).toExist()
    expect(tags.next()).toBe('.annotator-editor-controls')

  it "should set the value of the input if an annotation is given to annotationEditorShown", ->
    annotation = { tags: ['foo', 'bar', 'baz'] }
    $(t.element).trigger('annotationEditorShown', [t.element, annotation])
    tags = $(t.element).find('input.annotator-editor-tags')
    expect(tags.val()).toEqual('foo bar baz')

  it "should set the annotation's tags from the element on annotationEditorSubmit", ->
    # Create element with tags from annotation
    annotation = { tags: ['foo', 'bar', 'baz'] }
    $(t.element).trigger('annotationEditorShown', [t.element, annotation])

    # Overwrite the tags in the DOM, as if an editing user
    tags = $(t.element).find('input.annotator-editor-tags')
    tags.val('updated in dom')
    $(t.element).trigger('annotationEditorSubmit', [t.element, annotation])

    expect(annotation.tags).toEqual(['updated', 'in', 'dom'])

  it "should clear the element on annotationEditorHidden", ->
    # Create element with tags from annotation
    annotation = { tags: ['foo', 'bar', 'baz'] }
    $(t.element).trigger('annotationEditorShown', [t.element, annotation])

    tags = $(t.element).find('input.annotator-editor-tags')
    $(t.element).trigger('annotationEditorHidden', [t.element, annotation])

    expect(tags.val()).toEqual('')

  it "should show the tags on annotationViewerShown", ->

