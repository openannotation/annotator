describe "Annotator.Plugin.Store", ->
  store = null

  beforeEach ->
    element = $('<div></div>')[0]
    store = new Annotator.Plugin.Store(element, {autoFetch: false})

  describe "events", ->
    it "should call annotationCreated when the annotationCreated is fired", ->
      spyOn(store, 'annotationCreated')
      store.element.trigger('annotationCreated', ['annotation1'])
      expect(store.annotationCreated).toHaveBeenCalledWith('annotation1')

    it "should call annotationUpdated when the annotationUpdated is fired", ->
      spyOn(store, 'annotationUpdated')
      store.element.trigger('annotationUpdated', ['annotation1'])
      expect(store.annotationUpdated).toHaveBeenCalledWith('annotation1')

    it "should call annotationDeleted when the annotationDeleted is fired", ->
      spyOn(store, 'annotationDeleted')
      store.element.trigger('annotationDeleted', ['annotation1'])
      expect(store.annotationDeleted).toHaveBeenCalledWith('annotation1')

  describe "_urlFor", ->
    it "should generate RESTful URLs by default", ->
      expect(store._urlFor('create')).toEqual('/store/annotations')
      expect(store._urlFor('read')).toEqual('/store/annotations')
      expect(store._urlFor('read', 'foo')).toEqual('/store/annotations/foo')
      expect(store._urlFor('update', 'bar')).toEqual('/store/annotations/bar')
      expect(store._urlFor('destroy', 'baz')).toEqual('/store/annotations/baz')

    it "should generate URLs as specified by its options otherwise", ->
      store.options.prefix = '/some/prefix/'
      store.options.urls.create = 'createMe'
      store.options.urls.read = ':id/readMe'
      store.options.urls.update = ':id/updateMe'
      store.options.urls.destroy = ':id/destroyMe'
      expect(store._urlFor('create')).toEqual('/some/prefix/createMe')
      expect(store._urlFor('read')).toEqual('/some/prefix/readMe')
      expect(store._urlFor('read', 'foo')).toEqual('/some/prefix/foo/readMe')
      expect(store._urlFor('update', 'bar')).toEqual('/some/prefix/bar/updateMe')
      expect(store._urlFor('destroy', 'baz')).toEqual('/some/prefix/baz/destroyMe')

  describe "dumpAnnotations", ->
    it "returns a list of its annotations", ->
      store.annotations = [{text: "Foobar"}, {user: "Bob"}]
      expect(store.dumpAnnotations()).toEqual([{text: "Foobar"}, {user: "Bob"}])

    it "removes the highlights properties from the annotations", ->
      store.annotations = [{highlights: "abc"}, {highlights: [1,2,3]}]
      expect(store.dumpAnnotations()).toEqual([{}, {}])
