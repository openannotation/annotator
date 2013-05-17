describe "Annotator.Plugin.Store", ->
  store = null

  beforeEach ->
    element = $('<div></div>')[0]
    store = new Annotator.Plugin.Store(element, {autoFetch: false})
    store.annotator = {
      plugins: {}
      loadAnnotations: sinon.spy()
    }

  describe "events", ->
    it "should call Store#annotationCreated when the annotationCreated is fired", ->
      sinon.stub(store, 'annotationCreated')
      store.element.trigger('annotationCreated', ['annotation1'])
      assert.isTrue(store.annotationCreated.calledWith('annotation1'))

    it "should call Store#annotationUpdated when the annotationUpdated is fired", ->
      sinon.stub(store, 'annotationUpdated')
      store.element.trigger('annotationUpdated', ['annotation1'])
      assert.isTrue(store.annotationUpdated.calledWith('annotation1'))

    it "should call Store#annotationDeleted when the annotationDeleted is fired", ->
      sinon.stub(store, 'annotationDeleted')
      store.element.trigger('annotationDeleted', ['annotation1'])
      assert.isTrue(store.annotationDeleted.calledWith('annotation1'))

  describe "pluginInit", ->
    it "should call Store#_getAnnotations() if no Auth plugin is loaded", ->
      sinon.stub(store, '_getAnnotations')
      store.pluginInit()
      assert(store._getAnnotations.calledOnce)

    it "should call Auth#withToken() if Auth plugin is loaded", ->
      authMock = {
        withToken: sinon.spy()
      }
      store.annotator.plugins.Auth = authMock

      store.pluginInit()
      assert.isTrue(authMock.withToken.calledWith(store._getAnnotations))

  describe "_getAnnotations", ->
    it "should call Store#loadAnnotations() if @options.loadFromSearch is not present", ->
      sinon.stub(store, 'loadAnnotations')
      store._getAnnotations()
      assert(store.loadAnnotations.calledOnce)

    it "should call Store#loadAnnotationsFromSearch() if @options.loadFromSearch is present", ->
      sinon.stub(store, 'loadAnnotationsFromSearch')

      store.options.loadFromSearch = {}
      store._getAnnotations()

      assert.isTrue(store.loadAnnotationsFromSearch.calledWith(store.options.loadFromSearch))

  describe "annotationCreated", ->
    annotation = null

    beforeEach ->
      annotation = {}
      sinon.stub(store, 'registerAnnotation')
      sinon.stub(store, 'updateAnnotation')
      sinon.stub(store, '_apiRequest')

    it "should call Store#registerAnnotation() with the new annotation", ->
      store.annotationCreated(annotation)
      assert.isTrue(store.registerAnnotation.calledWith(annotation))

    it "should call Store#_apiRequest('create') with the new annotation", ->
      store.annotationCreated(annotation)
      args = store._apiRequest.lastCall.args

      assert(store._apiRequest.calledOnce)
      assert.equal(args[0], 'create')
      assert.equal(args[1], annotation)

    it "should call Store#updateAnnotation() if the annotation already exists in @annotations", ->
      store.annotations = [annotation]
      store.annotationCreated(annotation)
      assert(store.updateAnnotation.calledOnce)
      assert.equal(store.updateAnnotation.lastCall.args[0], annotation)

  describe "annotationUpdated", ->
    annotation = null

    beforeEach ->
      annotation = {}
      sinon.stub(store, '_apiRequest')

    it "should call Store#_apiRequest('update') with the annotation and data", ->
      store.annotations = [annotation]
      store.annotationUpdated(annotation)
      args = store._apiRequest.lastCall.args

      assert(store._apiRequest.calledOnce)
      assert.equal(args[0], 'update')
      assert.equal(args[1], annotation)
      assert.equal(typeof args[2], 'function')

      # Ensure the request callback works as expected.
      sinon.stub(store, 'updateAnnotation');

      data = {text: "Dummy response data"}
      args[2](data)
      assert.isTrue(store.updateAnnotation.calledWith(annotation, data))

    it "should NOT call Store#_apiRequest() if the annotation is unregistered", ->
      store.annotations = []
      store.annotationUpdated(annotation)

      assert.isFalse(store._apiRequest.called)

  describe "annotationDeleted", ->
    annotation = null

    beforeEach ->
      annotation = {}
      sinon.stub(store, '_apiRequest')

    it "should call Store#_apiRequest('destroy') with the annotation and data", ->
      store.annotations = [annotation]
      store.annotationDeleted(annotation)
      args = store._apiRequest.lastCall.args

      assert(store._apiRequest.calledOnce)
      assert.equal(args[0], 'destroy')
      assert.equal(args[1], annotation)

    it "should NOT call Store#_apiRequest() if the annotation is unregistered", ->
      store.annotations = []
      store.annotationDeleted(annotation)

      assert.isFalse(store._apiRequest.called)

  describe "registerAnnotation", ->
    it "should add the annotation to the @annotations array", ->
      annotation = {}
      store.annotations = []
      store.registerAnnotation(annotation)
      assert.equal($.inArray(annotation, store.annotations), 0)

  describe "unregisterAnnotation", ->
    it "should remove the annotation from the @annotations array", ->
      annotation = {}
      store.annotations = [annotation]
      store.unregisterAnnotation(annotation)
      assert.equal($.inArray(annotation, store.annotations), -1)

  describe "updateAnnotation", ->
    annotation = {}

    beforeEach ->
      sinon.stub(console, 'error')
      annotation = {
        text: "my annotation text"
        range: []
      }
      store.annotations = [annotation]

    afterEach ->
      console.error.restore()

    it "should extend the annotation with the data provided", ->
      store.updateAnnotation(annotation, {
        id: "myid"
        text: "new text"
      })
      assert.deepEqual(annotation, {
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
      assert.equal(annotation, annotation)

    it "should update the data stored on the annotation highlight", ->
      data = {}
      annotation.highlight = $('<span />').data('annotation', annotation)
      store.updateAnnotation(annotation, data)
      assert.equal(annotation.highlight.data('annotation'), annotation)

  describe "loadAnnotations", ->
    it "should call Store#_apiRequest()", ->
      sinon.stub(store, '_apiRequest')
      store.loadAnnotations()
      assert.isTrue(store._apiRequest.calledWith('read', null, store._onLoadAnnotations))

  describe "loadAnnotationsFromSearch", ->
    it "should call Store#_apiRequest()", ->
      options = {}

      sinon.stub(store, '_apiRequest')
      store.loadAnnotationsFromSearch(options)

      assert.isTrue(store._apiRequest.calledWith('search', options, store._onLoadAnnotationsFromSearch))

  describe "_onLoadAnnotations", ->
    it "should set the Store#annotations property with received annotations", ->
      data = [1,2,3];
      store._onLoadAnnotations(data)
      assert.deepEqual(store.annotations, data)

    it "should default to an empty array if no data is provided", ->
      store._onLoadAnnotations()
      assert.deepEqual(store.annotations, [])

    it "should call Annotator#loadAnnotations()", ->
      store._onLoadAnnotations()
      assert(store.annotator.loadAnnotations.calledOnce)

    it "should call Annotator#loadAnnotations() with clone of provided data", ->
      data = [];
      store._onLoadAnnotations(data)
      assert.notStrictEqual(store.annotator.loadAnnotations.lastCall.args[0], data)
      assert.deepEqual(store.annotator.loadAnnotations.lastCall.args[0], data)

    it "should add, dedupe and update annotations when called for the 2nd time", ->
      data1 = [{id: 1}, {id: 2}]
      data2 = [{id: 1, foo: "bar"}, {id: 3}]
      dataAll = [{id: 1, foo: "bar"}, {id: 2}, {id: 3}]
      store._onLoadAnnotations(data1)
      store._onLoadAnnotations(data2)
      assert.deepEqual(store.annotations, dataAll)

  describe "_onLoadAnnotationsFromSearch", ->
    it "should call Store#_onLoadAnnotations() with data.rows", ->
      sinon.stub(store, '_onLoadAnnotations')

      data = {rows: [{}, {}, {}]}
      store._onLoadAnnotationsFromSearch(data)
      assert.deepEqual(store._onLoadAnnotations.lastCall.args[0], data.rows)

    it "should default to an empty array if no data.rows are provided", ->
      sinon.stub(store, '_onLoadAnnotations')

      store._onLoadAnnotationsFromSearch()
      assert.deepEqual(store._onLoadAnnotations.lastCall.args[0], [])

  describe "dumpAnnotations", ->
    it "returns a list of its annotations", ->
      store.annotations = [{text: "Foobar"}, {user: "Bob"}]
      assert.deepEqual(store.dumpAnnotations(), [{text: "Foobar"}, {user: "Bob"}])

    it "removes the highlights properties from the annotations", ->
      store.annotations = [{highlights: "abc"}, {highlights: [1,2,3]}]
      assert.deepEqual(store.dumpAnnotations(), [{}, {}])

  describe "_apiRequest", ->
    mockUri     = 'http://mock.com'
    mockOptions = {}

    beforeEach ->
      sinon.stub(store, '_urlFor').returns(mockUri)
      sinon.stub(store, '_apiRequestOptions').returns(mockOptions)
      sinon.stub($, 'ajax').returns({})

    afterEach ->
      $.ajax.restore()

    it "should call Store#_urlFor() with the action", ->
      action = 'read'

      store._apiRequest(action)
      assert.isTrue(store._urlFor.calledWith(action, undefined))

    it "should call Store#_urlFor() with the action and id extracted from the data", ->
      data   = {id: 'myId'}
      action = 'read'

      store._apiRequest(action, data)
      assert.isTrue(store._urlFor.calledWith(action, data.id))

    it "should call Store#_apiRequestOptions() with the action, data and callback", ->
      data     = {id: 'myId'}
      action   = 'read'
      callback = ->

      store._apiRequest(action, data, callback)
      assert.isTrue(store._apiRequestOptions.calledWith(action, data, callback))

    it "should call jQuery#ajax()", ->
      store._apiRequest()
      assert.isTrue($.ajax.calledWith(mockUri, mockOptions))

    it "should return the jQuery XHR object with action and id appended", ->
      data     = {id: 'myId'}
      action   = 'read'

      request = store._apiRequest(action, data)
      assert.equal(request._id, data.id)
      assert.equal(request._action, action)

  describe "_apiRequestOptions", ->
    beforeEach ->
      sinon.stub(store, '_dataFor').returns('{}')

    it "should call Store#_methodFor() with the action", ->
      sinon.stub(store, '_methodFor').returns('GET')
      action = 'read'
      store._apiRequestOptions(action)
      assert.isTrue(store._methodFor.calledWith(action))

    it "should return options for jQuery.ajax()", ->
      sinon.stub(store, '_methodFor').returns('GET')
      action   = 'read'
      data     = {}
      callback = ->

      options = store._apiRequestOptions(action, data, callback)
      assert.deepEqual(options, {
        type:        'GET'
        headers:     undefined
        dataType:    "json"
        success:     callback
        error:       store._onError
        data:        '{}'
        contentType: "application/json; charset=utf-8"
      })

    it "should set custom headers from the data property 'annotator:headers'", ->
      sinon.stub(store, '_methodFor').returns('GET')
      sinon.stub(store.element, 'data').returns({
        'x-custom-header-one':   'mycustomheader'
        'x-custom-header-two':   'mycustomheadertwo'
        'x-custom-header-three': 'mycustomheaderthree'
      })

      action   = 'read'
      data     = {}

      options = store._apiRequestOptions(action, data)

      assert.deepEqual(options.headers, {
        'x-custom-header-one':   'mycustomheader'
        'x-custom-header-two':   'mycustomheadertwo'
        'x-custom-header-three': 'mycustomheaderthree'
      })

    it "should call Store#_dataFor() with the data if action is NOT search", ->
      sinon.stub(store, '_methodFor').returns('GET')
      action = 'read'
      data   = {}
      store._apiRequestOptions(action, data)
      assert.isTrue(store._dataFor.calledWith(data))

    it "should NOT call Store#_dataFor() if action is search", ->
      sinon.stub(store, '_methodFor').returns('GET')
      action = 'search'
      data   = {}
      store._apiRequestOptions(action, data)
      assert.isFalse(store._dataFor.called)

    it "should NOT add the contentType property if the action is search", ->
      sinon.stub(store, '_methodFor').returns('GET')
      action   = 'search'
      data     = {}

      options = store._apiRequestOptions(action, data)
      assert.isUndefined(options.contentType)
      assert.equal(options.data, data)

    it "should emulate new-fangled HTTP if emulateHTTP is true", ->
      sinon.stub(store, '_methodFor').returns('DELETE')

      store.options.emulateHTTP = true
      options = store._apiRequestOptions('destroy', {id: 4})

      assert.equal(options.type, 'POST')
      assert.deepEqual(options.headers, {
        'X-HTTP-Method-Override': 'DELETE'
      })

    it "should emulate proper JSON handling if emulateJSON is true", ->
      sinon.stub(store, '_methodFor').returns('DELETE')

      store.options.emulateJSON = true
      options = store._apiRequestOptions('destroy', {})

      assert.deepEqual(options.data, {
        json: '{}',
      })
      assert.isUndefined(options.contentType)

    it "should append _method to the form data if emulateHTTP and emulateJSON are both true", ->
      sinon.stub(store, '_methodFor').returns('DELETE')

      store.options.emulateHTTP = true
      store.options.emulateJSON = true
      options = store._apiRequestOptions('destroy', {})

      assert.deepEqual(options.data, {
        _method: 'DELETE',
        json: '{}',
      })

  describe "_urlFor", ->
    it "should generate RESTful URLs by default", ->
      assert.equal(store._urlFor('create'), '/store/annotations')
      assert.equal(store._urlFor('read'), '/store/annotations')
      assert.equal(store._urlFor('read', 'foo'), '/store/annotations/foo')
      assert.equal(store._urlFor('update', 'bar'), '/store/annotations/bar')
      assert.equal(store._urlFor('destroy', 'baz'), '/store/annotations/baz')

    it "should generate URLs as specified by its options otherwise", ->
      store.options.prefix = '/some/prefix'
      store.options.urls.create = '/createMe'
      store.options.urls.read = '/:id/readMe'
      store.options.urls.update = '/:id/updateMe'
      store.options.urls.destroy = '/:id/destroyMe'
      assert.equal(store._urlFor('create'), '/some/prefix/createMe')
      assert.equal(store._urlFor('read'), '/some/prefix/readMe')
      assert.equal(store._urlFor('read', 'foo'), '/some/prefix/foo/readMe')
      assert.equal(store._urlFor('update', 'bar'), '/some/prefix/bar/updateMe')
      assert.equal(store._urlFor('destroy', 'baz'), '/some/prefix/baz/destroyMe')

    it "should generate URLs correctly with an empty prefix", ->
      store.options.prefix = ''
      store.options.urls.create = '/createMe'
      store.options.urls.read = '/:id/readMe'
      store.options.urls.update = '/:id/updateMe'
      store.options.urls.destroy = '/:id/destroyMe'
      assert.equal(store._urlFor('create'), '/createMe')
      assert.equal(store._urlFor('read'), '/readMe')
      assert.equal(store._urlFor('read', 'foo'), '/foo/readMe')
      assert.equal(store._urlFor('update', 'bar'), '/bar/updateMe')
      assert.equal(store._urlFor('destroy', 'baz'), '/baz/destroyMe')

    it "should generate URLs with substitution markers in query strings", ->
      store.options.prefix = '/some/prefix'
      store.options.urls.read = '/read?id=:id'
      store.options.urls.update = '/update?foo&id=:id'
      store.options.urls.destroy = '/delete?id=:id&foo'
      assert.equal(store._urlFor('read'), '/some/prefix/read?id=')
      assert.equal(store._urlFor('read', 'foo'), '/some/prefix/read?id=foo')
      assert.equal(store._urlFor('update', 'bar'), '/some/prefix/update?foo&id=bar')
      assert.equal(store._urlFor('destroy', 'baz'), '/some/prefix/delete?id=baz&foo')

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
        assert.equal(store._methodFor action, method)

  describe "_dataFor", ->
    it "should stringify the annotation into JSON", ->
      annotation = {id: 'bill'}
      data = store._dataFor(annotation)
      assert.equal(data, '{"id":"bill"}')

    it "should NOT stringify the highlights property", ->
      annotation = {id: 'bill', highlights: {}}
      data = store._dataFor(annotation)
      assert.equal(data, '{"id":"bill"}')

    it "should NOT append a highlights property if the annotation does not have one", ->
      annotation = {id: 'bill'}
      store._dataFor(annotation)
      assert.isFalse(annotation.hasOwnProperty('highlights'))

    it "should extend the annotation with @options.annotationData", ->
      annotation = {id: "cat"}
      store.options.annotationData = {custom: 'value', customArray: []}
      data = store._dataFor(annotation)

      assert.equal(data, '{"id":"cat","custom":"value","customArray":[]}')
      assert.deepEqual(annotation, {"id":"cat", "custom":"value", "customArray":[]})

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
      sinon.stub(Annotator, 'showNotification')
      sinon.stub(console,   'error')

      store._onError requests.shift()
      message = Annotator.showNotification.lastCall.args[0]

    afterEach ->
      Annotator.showNotification.restore()
      console.error.restore()

    it "should call call Annotator.showNotification() with a message and error style", ->
      assert(Annotator.showNotification.calledOnce)
      assert.equal(Annotator.showNotification.lastCall.args[1], Annotator.Notification.ERROR)

    it "should call console.error with a message", ->
      assert(console.error.calledOnce)

    it "should give a default message if xhr.status id not provided", ->
      assert.equal(message, "Sorry we could not read this annotation")

    it "should give a default specific message if xhr._action is 'search'", ->
      assert.equal(message, "Sorry we could not search the store for annotations")

    it "should give a default specific message if xhr._action is 'read' and there is no xhr._id", ->
      assert.equal(message, "Sorry we could not read the annotations from the store")

    it "should give a specific message if xhr.status == 401", ->
      assert.equal(message, "Sorry you are not allowed to delete this annotation")

    it "should give a specific message if xhr.status == 404", ->
      assert.equal(message, "Sorry we could not connect to the annotations store")

    it "should give a specific message if xhr.status == 500", ->
      assert.equal(message, "Sorry something went wrong with the annotation store")
