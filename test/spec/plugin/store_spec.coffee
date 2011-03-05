describe "Annotator.Plugin.Store", ->
  store = null

  beforeEach ->
    element = $('<div></div>')[0]
    store = new Annotator.Plugin.Store(element, {autoFetch: false})
    store.annotator = {
      loadAnnotations: jasmine.createSpy('Annotator#loadAnnotations')
    }

  describe "events", ->
    it "should call Store#annotationCreated when the annotationCreated is fired", ->
      spyOn(store, 'annotationCreated')
      store.element.trigger('annotationCreated', ['annotation1'])
      expect(store.annotationCreated).toHaveBeenCalledWith('annotation1')

    it "should call Store#annotationUpdated when the annotationUpdated is fired", ->
      spyOn(store, 'annotationUpdated')
      store.element.trigger('annotationUpdated', ['annotation1'])
      expect(store.annotationUpdated).toHaveBeenCalledWith('annotation1')

    it "should call Store#annotationDeleted when the annotationDeleted is fired", ->
      spyOn(store, 'annotationDeleted')
      store.element.trigger('annotationDeleted', ['annotation1'])
      expect(store.annotationDeleted).toHaveBeenCalledWith('annotation1')

  describe "pluginInit", ->
    it "should call Store#_getAnnotations() if no Auth plugin is loaded", ->
      spyOn(store, '_getAnnotations')
      store.pluginInit()
      expect(store._getAnnotations).toHaveBeenCalled()

    it "should call Auth#withToken() if Auth plugin is loaded", ->
      authMock = {
        withToken: jasmine.createSpy('Auth#withToken()')
      }
      store.element.data('annotator:auth', authMock);

      store.pluginInit()
      expect(authMock.withToken).toHaveBeenCalledWith(store._getAnnotations)

  describe "_getAnnotations", ->
    it "should call Store#loadAnnotations() if @options.loadFromSearch is not present", ->
      spyOn(store, 'loadAnnotations')
      store._getAnnotations()
      expect(store.loadAnnotations).toHaveBeenCalled()

    it "should call Store#loadAnnotationsFromSearch() if @options.loadFromSearch is present", ->
      spyOn(store, 'loadAnnotationsFromSearch')

      store.options.loadFromSearch = {}
      store._getAnnotations()

      expect(store.loadAnnotationsFromSearch).toHaveBeenCalledWith(store.options.loadFromSearch)

  describe "loadAnnotations", ->
    it "should call Store#_apiRequest()", ->
      spyOn(store, '_apiRequest')
      store.loadAnnotations()
      expect(store._apiRequest).toHaveBeenCalledWith('read', null, store._onLoadAnnotations)

  describe "loadAnnotationsFromSearch", ->
    it "should call Store#_apiRequest()", ->
      options = {}

      spyOn(store, '_apiRequest')
      store.loadAnnotationsFromSearch(options)

      expect(store._apiRequest).toHaveBeenCalledWith('search', options, store._onLoadAnnotationsFromSearch)

  describe "_onLoadAnnotations", ->
    it "should set the Store#annotations property with received annotations", ->
      data = [1,2,3];
      store._onLoadAnnotations(data)
      expect(store.annotations).toBe(data)

    it "should default to an empty array if no data is provided", ->
      store._onLoadAnnotations()
      expect(store.annotations).toEqual([])

    it "should call Annotator#loadAnnotations()", ->
      store._onLoadAnnotations()
      expect(store.annotator.loadAnnotations).toHaveBeenCalled()

    it "should call Annotator#loadAnnotations() with clone of provided data", ->
      data = [];
      store._onLoadAnnotations(data)
      expect(store.annotator.loadAnnotations.mostRecentCall.args[0]).not.toBe(data)
      expect(store.annotator.loadAnnotations.mostRecentCall.args[0]).toEqual(data)

  describe "_onLoadAnnotationsFromSearch", ->
    it "should call Store#_onLoadAnnotations() with data.rows", ->
      spyOn(store, '_onLoadAnnotations')

      data = {rows: [{}, {}, {}]}
      store._onLoadAnnotationsFromSearch(data)
      expect(store._onLoadAnnotations.mostRecentCall.args[0]).toEqual(data.rows)

    it "should default to an empty array if no data.rows are provided", ->
      spyOn(store, '_onLoadAnnotations')

      store._onLoadAnnotationsFromSearch()
      expect(store._onLoadAnnotations.mostRecentCall.args[0]).toEqual([])

  describe "dumpAnnotations", ->
    it "returns a list of its annotations", ->
      store.annotations = [{text: "Foobar"}, {user: "Bob"}]
      expect(store.dumpAnnotations()).toEqual([{text: "Foobar"}, {user: "Bob"}])

    it "removes the highlights properties from the annotations", ->
      store.annotations = [{highlights: "abc"}, {highlights: [1,2,3]}]
      expect(store.dumpAnnotations()).toEqual([{}, {}])

  describe "_apiRequest", ->
    mockUri     = 'http://mock.com'
    mockOptions = {}

    beforeEach ->
      spyOn(store, '_urlFor').andReturn(mockUri)
      spyOn(store, '_apiRequestOptions').andReturn(mockOptions)
      spyOn($, 'ajax').andReturn({})

    it "should call Store#_urlFor() with the action", ->
      action = 'read'

      store._apiRequest(action)
      expect(store._urlFor).toHaveBeenCalledWith(action, undefined)

    it "should call Store#_urlFor() with the action and id extracted from the data", ->
      data   = {id: 'myId'}
      action = 'read'

      store._apiRequest(action, data)
      expect(store._urlFor).toHaveBeenCalledWith(action, data.id)

    it "should call Store#_apiRequestOptions() with the action, data and callback", ->
      data     = {id: 'myId'}
      action   = 'read'
      callback = ->

      store._apiRequest(action, data, callback)
      expect(store._apiRequestOptions).toHaveBeenCalledWith(action, data, callback)

    it "should call jQuery#ajax()", ->
      store._apiRequest()
      expect($.ajax).toHaveBeenCalledWith(mockUri, mockOptions)

    it "should return the jQuery XHR object with action and id appended", ->
      data     = {id: 'myId'}
      action   = 'read'

      request = store._apiRequest(action, data)
      expect(request._id).toBe(data.id)
      expect(request._action).toBe(action)

  describe "_apiRequestOptions", ->
    beforeEach ->
      spyOn(store, '_methodFor').andReturn('GET')
      spyOn(store, '_dataFor').andReturn('{}')

    it "should call Store#_methodFor() with the action", ->
      action = 'read'
      store._apiRequestOptions(action)
      expect(store._methodFor).toHaveBeenCalledWith(action)

    it "should return options for jQuery.ajax()", ->
      action   = 'read'
      data     = {}
      callback = ->

      options = store._apiRequestOptions(action, data, callback)
      expect(options).toEqual({
        type:        'GET'
        beforeSend:  store._onBeforeSend
        dataType:    "json"
        success:     callback
        error:       store._onError
        data:        '{}'
        contentType: "application/json; charset=utf-8"
      })

    it "should call Store#_dataFor() with the data if action is NOT search", ->
      action = 'read'
      data   = {}
      store._apiRequestOptions(action, data)
      expect(store._dataFor).toHaveBeenCalledWith(data)

    it "should NOT call Store#_dataFor() if action is search", ->
      action = 'search'
      data   = {}
      store._apiRequestOptions(action, data)
      expect(store._dataFor).not.toHaveBeenCalled()

    it "should NOT add the contentType property if the action is search", ->
      action   = 'search'
      data     = {}

      options = store._apiRequestOptions(action, data)
      expect(options.contentType).toBeUndefined()
      expect(options.data).toBe(data)

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

  describe "_methodFor", ->
    it "should return the appropriate method for the action", ->
      table = {
        'create':  'POST'
        'read':    'GET'
        'update':  'PUT'
        'destroy': 'DELETE'
        'search':  'GET'
      }
      for action, method in table
        expect(store._methodFor action).toEqual(method)

  describe "_dataFor", ->
    it "should stringify the annotation into JSON", ->
      annotation = {id: 'bill'}
      data = store._dataFor(annotation)
      expect(data).toBe('{"id":"bill"}')

    it "should NOT stringify the highlights property", ->
      annotation = {id: 'bill', highlights: {}}
      data = store._dataFor(annotation)
      expect(data).toBe('{"id":"bill"}')

    it "should NOT append a highlights property if the annotation does not have one", ->
      annotation = {id: 'bill'}
      store._dataFor(annotation)
      expect(annotation.hasOwnProperty('highlights')).toBeFalsy()

    it "should extend the annotation with @options.annotationData", ->
      annotation = {id: "cat"}
      store.options.annotationData = {custom: 'value', customArray: []}
      data = store._dataFor(annotation)
      
      expect(data).toEqual('{"id":"cat","custom":"value","customArray":[]}')
      expect(annotation).toEqual({"id":"cat", "custom":"value", "customArray":[]})
