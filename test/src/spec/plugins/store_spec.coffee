$ = jQuery

describe "Annotator.Plugins.Store", ->
  a = null
  el = null

  beforeEach ->
    el = $('<div></div>')[0]
    a = new Annotator.Plugins.Store(el)

  xit "should save an annotation on an annotationCreated event", ->
    mockAjax('store')
    expect(a.annotations).toEqual([])
    mock_request().and_return('', 'text/plain')
    expect(a).should(receive, 'annotationCreated', 'once').with_args(null, 'annotation1')
    # Trigger annotationCreated event for 'annotation1'
    $(el).trigger('annotationCreated', ['annotation1'])
    expect(a.annotations).toEqual(['annotation1'])

  xit "should extend the annotation data it sends to the the backend \
    with the contents of the annotationData object", ->
    mock_request().and_return('[]', 'text/plain')
    a.options.annotationData = { one: 1, two: 2 }

    mock_request().and_return('', 'text/plain')

    $(el).trigger('annotationCreated', [{three: 3}])
    expect(a.annotations).toEqual([{one:1, two: 2, three: 3, highlights: undefined}])

  xit "should remove an annotation on an annotationDeleted event", ->
    # Add one annotation
    a.registerAnnotation('annotation1')
    expect(a.annotations).toEqual(['annotation1'])
    # Respond positively to the request to delete.
    mock_request().and_return('', 'text/plain')
    # Check the annotationDeleted method is called.
    expect(a).should(receive, 'annotationDeleted', 'once').with_args(null, 'annotation1')
    # Trigger annotationDeleted event for 'annotation1'.
    $(el).trigger('annotationDeleted', ['annotation1'])
    # Make sure annotation is no longer in the registry.
    expect(a.annotations).toEqual([])

  it "should generate RESTful URLs by default", ->
    expect(a._urlFor('create')).toEqual('/store/annotations')
    expect(a._urlFor('read')).toEqual('/store/annotations')
    expect(a._urlFor('read', 'foo')).toEqual('/store/annotations/foo')
    expect(a._urlFor('update', 'bar')).toEqual('/store/annotations/bar')
    expect(a._urlFor('destroy', 'baz')).toEqual('/store/annotations/baz')

  it "should generate URLs as specified by its options otherwise", ->
    a.options.prefix = '/some/prefix/'
    a.options.urls.create = 'createMe'
    a.options.urls.read = ':id/readMe'
    a.options.urls.update = ':id/updateMe'
    a.options.urls.destroy = ':id/destroyMe'
    expect(a._urlFor('create')).toEqual('/some/prefix/createMe')
    expect(a._urlFor('read')).toEqual('/some/prefix/readMe')
    expect(a._urlFor('read', 'foo')).toEqual('/some/prefix/foo/readMe')
    expect(a._urlFor('update', 'bar')).toEqual('/some/prefix/bar/updateMe')
    expect(a._urlFor('destroy', 'baz')).toEqual('/some/prefix/baz/destroyMe')

xdescribe "Annotator.Plugins.Store initialized with an empty backend", ->
  beforeEach ->
    el = $('<div></div>')[0]
    mock_request().and_return('[]', 'text/plain')
    a = new Annotator.Plugins.Store(el)

  it "should have no annotations", ->
    expect(a.annotations.length).toEqual(0)

xdescribe "Annotator.Plugins.Store with annotations in backend store", ->
  beforeEach ->
    el = $('<div></div>')[0]
    mock_request().and_return('[{"ranges":[],"text":"hello","id":1}]', 'text/plain')
    a = new Annotator.Plugins.Store(el)

  it "should load the annotations into its registry", ->
    expect(a.annotations).to(have_length, 1)
    expect(a.annotations[0].text).toEqual("hello")

