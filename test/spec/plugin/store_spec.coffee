describe "Annotator.Plugin.Store", ->
  store = null

  beforeEach ->
    element = $('<div></div>')[0]
    store = new Annotator.Plugin.Store(element, {autoFetch: false})
    store.annotator = {
      plugins: {}
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
      store.annotator.plugins.Auth = authMock

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

  describe "annotationCreated", ->
    annotation = null

    beforeEach ->
      annotation = {}
      spyOn(store, 'registerAnnotation')
      spyOn(store, 'updateAnnotation')
      spyOn(store, '_apiRequest')

    it "should call Store#registerAnnotation() with the new annotation", ->
      store.annotationCreated(annotation)
      expect(store.registerAnnotation).toHaveBeenCalledWith(annotation)

    it "should call Store#_apiRequest('create') with the new annotation", ->
      store.annotationCreated(annotation)
      args = store._apiRequest.mostRecentCall.args

      expect(store._apiRequest).toHaveBeenCalled()
      expect(args[0]).toBe('create')
      expect(args[1]).toBe(annotation)

    it "should call Store#updateAnnotation() if the annotation already exists in @annotations", ->
      store.annotations = [annotation]
      store.annotationCreated(annotation)
      expect(store.updateAnnotation).toHaveBeenCalled()
      expect(store.updateAnnotation.mostRecentCall.args[0]).toBe(annotation)

  describe "annotationUpdated", ->
    annotation = null

    beforeEach ->
      annotation = {}
      spyOn(store, '_apiRequest')

    it "should call Store#_apiRequest('update') with the annotation and data", ->
      store.annotations = [annotation]
      store.annotationUpdated(annotation)
      args = store._apiRequest.mostRecentCall.args

      expect(store._apiRequest).toHaveBeenCalled()
      expect(args[0]).toBe('update')
      expect(args[1]).toBe(annotation)
      expect(typeof args[2]).toBe('function')

      # Ensure the request callback works as expected.
      spyOn(store, 'updateAnnotation');

      data = {text: "Dummy response data"}
      args[2](data)
      expect(store.updateAnnotation).toHaveBeenCalledWith(annotation, data)

    it "should NOT call Store#_apiRequest() if the annotation is unregistered", ->
      store.annotations = []
      store.annotationUpdated(annotation)
      args = store._apiRequest.mostRecentCall.args

      expect(store._apiRequest).not.toHaveBeenCalled()

  describe "annotationDeleted", ->
    annotation = null

    beforeEach ->
      annotation = {}
      spyOn(store, '_apiRequest')

    it "should call Store#_apiRequest('destroy') with the annotation and data", ->
      store.annotations = [annotation]
      store.annotationDeleted(annotation)
      args = store._apiRequest.mostRecentCall.args

      expect(store._apiRequest).toHaveBeenCalled()
      expect(args[0]).toBe('destroy')
      expect(args[1]).toBe(annotation)

    it "should NOT call Store#_apiRequest() if the annotation is unregistered", ->
      store.annotations = []
      store.annotationDeleted(annotation)
      args = store._apiRequest.mostRecentCall.args

      expect(store._apiRequest).not.toHaveBeenCalled()

  describe "registerAnnotation", ->
    it "should add the annotation to the @annotations array", ->
      annotation = {}
      store.annotations = []
      store.registerAnnotation(annotation)
      expect($.inArray(annotation, store.annotations)).toBe(0)

  describe "unregisterAnnotation", ->
    it "should remove the annotation from the @annotations array", ->
      annotation = {}
      store.annotations = [annotation]
      store.unregisterAnnotation(annotation)
      expect($.inArray(annotation, store.annotations)).toBe(-1)

  describe "updateAnnotation", ->
    annotation = {}

    beforeEach ->
      spyOn(console, 'error')
      annotation = {
        text: "my annotation text"
        range: []
      }
      store.annotations = [annotation]

    it "should extend the annotation with the data provided", ->
      store.updateAnnotation(annotation, {
        id: "myid"
        text: "new text"
      })
      expect(annotation).toEqual({
        id: "myid"
        text: "new text"
        range: []
      })

    it "should NOT extend the annotation if it is not registered with the Store", ->
      store.annotations = []
      store.updateAnnotation(annotation, {
        id: "myid"
        text: "new text"
      })
      expect(annotation).toEqual(annotation)

    it "should update the data stored on the annotation highlight", ->
      data = {}
      annotation.highlight = $('<span />').data('annotation', annotation)
      store.updateAnnotation(annotation, data)
      expect(annotation.highlight.data('annotation')).toBe(annotation)

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
        headers:     undefined
        dataType:    "json"
        success:     callback
        error:       store._onError
        data:        '{}'
        contentType: "application/json; charset=utf-8"
      })

    it "should set custom headers from the data property 'annotator:headers'", ->
      spyOn(store.element, 'data').andReturn({
        'x-custom-header-one':   'mycustomheader'
        'x-custom-header-two':   'mycustomheadertwo'
        'x-custom-header-three': 'mycustomheaderthree'
      })

      action   = 'read'
      data     = {}

      options = store._apiRequestOptions(action, data)

      expect(options.headers).toEqual({
        'x-custom-header-one':   'mycustomheader'
        'x-custom-header-two':   'mycustomheadertwo'
        'x-custom-header-three': 'mycustomheaderthree'
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

  describe "_onError", ->
    message = null
    requests = [
      {}
      {}
      {_action: 'read', _id: 'jim'}
      {_action: 'search'}
      {_action: 'read'}
      {status: 401, _action: 'delete', '_id': 'cake'}
      {status: 404, _action: 'delete', '_id': 'cake'}
      {status: 500, _action: 'delete', '_id': 'cake'}
    ]

    beforeEach ->
      spyOn(Annotator, 'showNotification')
      spyOn(console,   'error')

      store._onError requests.shift()
      message = Annotator.showNotification.mostRecentCall.args[0]

    it "should call call Annotator.showNotification() with a message and error style", ->
      expect(Annotator.showNotification).toHaveBeenCalled()
      expect(Annotator.showNotification.mostRecentCall.args[1]).toBe(Annotator.Notification.ERROR)

    it "should call console.error with a message", ->
      expect(console.error).toHaveBeenCalled()

    it "should give a default message if xhr.status id not provided", ->
      expect(message).toBe("Sorry we could not read this annotation")

    it "should give a default specific message if xhr._action is 'search'", ->
      expect(message).toBe("Sorry we could not search the store for annotations")

    it "should give a default specific message if xhr._action is 'read' and there is no xhr._id", ->
      expect(message).toBe("Sorry we could not read the annotations from the store")

    it "should give a specific message if xhr.status == 401", ->
      expect(message).toBe("Sorry you are not allowed to delete this annotation")

    it "should give a specific message if xhr.status == 404", ->
      expect(message).toBe("Sorry we could not connect to the annotations store")

    it "should give a specific message if xhr.status == 500", ->
      expect(message).toBe("Sorry something went wrong with the annotation store")
