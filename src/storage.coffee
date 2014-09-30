Util = require('./util')

$ = Util.$
_t = Util.TranslationString
Promise = Util.Promise

# Get a unique identifier
id = (-> counter = -1; -> counter += 1)()


# DebugStorage is a storage component that can be used to print details of the
# annotation persistence processes to the console when developing other parts of
# Annotator.
DebugStorage = ->
  trace = (action, annotation) ->
    copyAnno = JSON.parse(JSON.stringify(annotation))
    console.debug("DebugStore: #{action}", copyAnno)

  return {
    create: (annotation) ->
      annotation.id = id()
      trace('create', annotation)
      return annotation

    update: (annotation) ->
      trace('update', annotation)
      return annotation

    delete: (annotation) ->
      trace('destroy', annotation)
      return annotation

    query: (queryObj) ->
      trace('query', queryObj)
      return {results: [], metadata: {total: 0}}
  }


# NullStorage is a no-op storage component. It swallows all calls and does the
# bare minimum needed. Needless to say, it does not provide any real
# persistence.
NullStorage = ->

  # Public: create an annotation
  #
  # annotation - An annotation Object to create.
  #
  # Returns an annotation Object.
  create: (annotation) ->
    if not annotation.id?
      annotation.id = id()
    return annotation

  # Public: update an annotation
  #
  # annotation - An annotation Object to be updated.
  #
  # Returns an annotation Object.
  update: (annotation) ->
    return annotation

  # Public: delete an annotation
  #
  # annotation - An annotation Object to be deleted.
  #
  # Returns an annotation Object.
  delete: (annotation) ->
    return annotation

  # Public: query the store for annotations
  #
  # queryObj - A query Object.
  #
  # Returns an Object representing query results.
  query: (queryObj) ->
    return {results: []}


# FIXME: remove the function shim around HTTPStorageImpl and just make it a
# function itself
class HTTPStorageImpl

  # Configuration options
  options:

    # Should the plugin emulate HTTP methods like PUT and DELETE for
    # interaction with legacy web servers? Setting this to `true` will fake
    # HTTP `PUT` and `DELETE` requests with an HTTP `POST`, and will set the
    # request header `X-HTTP-Method-Override` with the name of the desired
    # method.
    emulateHTTP: false

    # Should the plugin emulate JSON POST/PUT payloads by sending its requests
    # as application/x-www-form-urlencoded with a single key, "json"
    emulateJSON: false

    # A set of custom headers that will be sent with every request. See also the
    # setHeader method.
    headers: {}

    # Callback, called if a remote request throws an error
    onError: (message, xhr) ->
      console.error("API request failed: #{message}")

    # This is the API endpoint. If the server supports Cross Origin Resource
    # Sharing (CORS) a full URL can be used here.
    prefix: '/store'

    # The server URLs for each available action. These URLs can be anything but
    # must respond to the appropraite HTTP method. The token ":id" can be used
    # anywhere in the URL and will be replaced with the annotation id.
    #
    # create:  POST
    # update:  PUT
    # destroy: DELETE
    # search:  GET
    urls:
      create: '/annotations'
      update: '/annotations/:id'
      destroy: '/annotations/:id'
      search: '/search'

  # Public: Initialises the instance.
  #
  # options - An Object containing configuration options (optional).
  #
  # Returns a new instance.
  constructor: (options) ->
    @options = $.extend(true, {}, @options, options)

    if @options.onError?
      @onError = @options.onError

  # Public: Create an annotation.
  #
  # annotation - An annotation Object to create.
  #
  # Examples
  #
  #   store.create({text: "my new annotation comment"})
  #   # => Results in an HTTP POST request to the server containing the
  #   #    annotation as serialised JSON.
  #
  # Returns a jqXHR object.
  create: (annotation) ->
    this._apiRequest('create', annotation)

  # Public: Update an annotation.
  #
  # annotation - An annotation Object to update.
  #
  # Examples
  #
  #   store.update({id: "blah", text: "updated annotation comment"})
  #   # => Results in an HTTP PUT request to the server containing the
  #   #    annotation as serialised JSON.
  #
  # Returns a jqXHR object.
  update: (annotation) ->
    this._apiRequest('update', annotation)

  # Public: Delete an annotation.
  #
  # annotation - An annotation Object that was deleted.
  #
  # Examples
  #
  #   store.delete({text: "my new annotation comment"})
  #   # => Results in an HTTP DELETE request to the server.
  #
  # Returns a jqXHR object.
  delete: (annotation) ->
    this._apiRequest('destroy', annotation)

  # Public: Searches for annotations matching the specified query.
  #
  # Returns a Promise resolving to the query results and query metadata.
  query: (queryObj) ->
    dfd = $.Deferred()
    this._apiRequest('search', queryObj)
    .done (obj) ->
      rows = obj.rows
      delete obj.row
      dfd.resolve({results: rows, metadata: obj})
    .fail ->
      dfd.reject.apply(dfd, arguments)
    return dfd.promise()

  # Public: Set a custom HTTP header to be sent with every request.
  #
  # key   - The header name.
  # value - The header value.
  #
  # Examples:
  #
  #   store.setHeader('X-My-Custom-Header', 'MyCustomValue')
  #
  # Returns nothing.
  setHeader: (key, value) ->
    this.options.headers[key] = value

  # Private: Helper method to build an XHR request for a specified action and
  # object.
  #
  # action - The action String: "search", "create", "update" or "destroy".
  # obj - The data to be sent, either annotation object or query string.
  #
  # Returns XMLHttpRequest object.
  _apiRequest: (action, obj) ->
    id = obj && obj.id
    url = this._urlFor(action, id)
    options = this._apiRequestOptions(action, obj)

    request = $.ajax(url, options)

    # Append the id and action to the request object
    # for use in the error callback.
    request._id = id
    request._action = action
    request

  # Builds an options object suitable for use in a jQuery.ajax() call.
  #
  # action - The action String: "search", "create", "update" or "destroy".
  # obj - The data to be sent, either annotation object or query string.
  #
  # Returns Object literal of $.ajax() options.
  _apiRequestOptions: (action, obj) ->
    method = this._methodFor(action)

    opts =
      type: method,
      dataType: "json",
      error: this._onError,
      headers: this.options.headers

    # If emulateHTTP is enabled, we send a POST and put the real method in an
    # HTTP request header.
    if @options.emulateHTTP and method in ['PUT', 'DELETE']
      opts.headers = $.extend(opts.headers, {'X-HTTP-Method-Override': method})
      opts.type = 'POST'

    # Don't JSONify obj if making search request.
    if action is "search"
      opts = $.extend(opts, data: obj)
      return opts

    data = obj && JSON.stringify(obj)

    # If emulateJSON is enabled, we send a form request (the correct
    # contentType will be set automatically by jQuery), and put the
    # JSON-encoded payload in the "json" key.
    if @options.emulateJSON
      opts.data = {json: data}
      if @options.emulateHTTP
        opts.data._method = method
      return opts

    opts = $.extend(opts, {
      data: data
      contentType: "application/json; charset=utf-8"
    })
    return opts

  # Builds the appropriate URL from the options for the action provided.
  #
  # action - The action String.
  # id     - The annotation id as a String or Number.
  #
  # Examples
  #
  #   store._urlFor('update', 34)
  #   # => Returns "/store/annotations/34"
  #
  #   store._urlFor('search')
  #   # => Returns "/store/search"
  #
  # Returns URL String.
  _urlFor: (action, id) ->
    url = if @options.prefix? then @options.prefix else ''
    url += @options.urls[action]
    # If there's a '/:id' in the URL, either fill in the ID or remove the
    # slash:
    url = url.replace(/\/:id/, if id? then '/' + id else '')
    # If there's a bare ':id' in the URL, then substitute directly:
    url = url.replace(/:id/, if id? then id else '')

    url

  # Maps an action to an HTTP method.
  #
  # action - The action String.
  #
  # Examples
  #
  #   store._methodFor('update')  # => "PUT"
  #   store._methodFor('destroy') # => "DELETE"
  #
  # Returns HTTP method String.
  _methodFor: (action) ->
    table =
      create: 'POST'
      update: 'PUT'
      destroy: 'DELETE'
      search: 'GET'

    table[action]

  # jQuery.ajax() callback. Displays an error notification to the user if
  # the request failed.
  #
  # xhr - The jqXMLHttpRequest object.
  #
  # Returns nothing.
  _onError: (xhr) ->
    action  = xhr._action
    message = _t("Sorry we could not ") + action + _t(" this annotation")

    if xhr._action == 'search'
      message = _t("Sorry we could not search the store for annotations")

    switch xhr.status
      when 401
        message = _t("Sorry you are not allowed to ") +
                  action +
                  _t(" this annotation")
      when 404
        message = _t("Sorry we could not connect to the annotations store")
      when 500
        message = _t("Sorry something went wrong with the annotation store")

    if typeof @onError == 'function'
      @onError(message, xhr)


# HTTPStorage is a storage component that talks to a simple remote API that can
# be implemented with any web framework.
HTTPStorage = (options) ->
  return new HTTPStorageImpl(options)


# StorageAdapter wraps a concrete implementation of the Storage interface, and
# ensures that the appropriate hooks are fired when annotations are created,
# updated, deleted, etc.
class StorageAdapter

  # Public: create a new storage adapter object.
  #
  # store - The Store implementation which manages persistence
  # runHook - A function which can be used to run lifecycle hooks
  constructor: (@store, @runHook) ->

  # Creates and returns a new annotation object.
  #
  # Runs the 'beforeAnnotationCreated' hook to allow the new annotation to be
  # initialized or its creation prevented.
  #
  # Runs the 'annotationCreated' hook when the new annotation has been created
  # by the store.
  #
  # annotation - An Object from which to create an annotation.
  #
  # Examples
  #
  #   registry.on 'beforeAnnotationCreated', (annotation) ->
  #     annotation.myProperty = 'This is a custom property'
  #   registry.create({}) # Resolves to {myProperty: "This is a…"}
  #
  # Returns a Promise of an annotation Object.
  create: (obj = {}) ->
    this._cycle(
      obj,
      'create',
      'onBeforeAnnotationCreated',
      'onAnnotationCreated'
    )

  # Updates an annotation.
  #
  # Runs the 'beforeAnnotationUpdated' hook to allow an annotation to be
  # modified before being passed to the store, or for an update to be prevented.
  #
  # Runs the 'annotationUpdated' hook when the annotation has been updated by
  # the store.
  #
  # annotation - An annotation Object to updated.
  #
  # Examples
  #
  #   annotation = {tags: 'apples oranges pears'}
  #   registry.on 'beforeAnnotationUpdated', (annotation) ->
  #     # validate or modify a property.
  #     annotation.tags = annotation.tags.split(' ')
  #   registry.update(annotation)
  #   # => Returns ["apples", "oranges", "pears"]
  #
  # Returns a Promise of an annotation Object.
  update: (obj) ->
    if not obj.id?
      throw new TypeError("annotation must have an id for update()")
    this._cycle(
      obj,
      'update',
      'onBeforeAnnotationUpdated',
      'onAnnotationUpdated'
    )

  # Public: Deletes the annotation.
  #
  # Runs the 'beforeAnnotationDeleted' hook to allow an annotation to be
  # modified before being passed to the store, or for the a deletion to be
  # prevented.
  #
  # Runs the 'annotationDeleted' hook when the annotation has been deleted by
  # the store.
  #
  # annotation - An annotation Object to delete.
  #
  # Returns a Promise of an annotation Object.
  delete: (obj) ->
    if not obj.id?
      throw new TypeError("annotation must have an id for delete()")
    this._cycle(
      obj,
      'delete',
      'onBeforeAnnotationDeleted',
      'onAnnotationDeleted'
    )

  # Public: Queries the store
  #
  # query - An Object defining a query. This may be interpreted differently by
  #         different stores.
  #
  # Returns a Promise resolving to the store return value.
  query: (query) ->
    return Promise.resolve(@store.query(query))

  # Public: Load and draw annotations from a given query.
  #
  # Runs the 'load' hook to allow plugins to respond to annotations being
  # loaded.
  #
  # query - the query to pass to the backend
  #
  # Returns a Promise that resolves when loading is complete.
  load: (query) ->
    this.query(query)
      .then (result) =>
        this.runHook('onAnnotationsLoaded', [result])

  # Private: cycle a store event, keeping track of the annotation object and
  # updating it as necessary.
  _cycle: (obj, storeFunc, beforeEvent, afterEvent) ->
    this.runHook(beforeEvent, [obj])
    .then =>
      safeCopy = $.extend(true, {}, obj)
      delete safeCopy._local

      # We use Promise.resolve() to coerce the result of the store function,
      # which can be either a value or a promise, to a promise.
      result = @store[storeFunc](safeCopy)
      Promise.resolve(result)
        .then (ret) =>
          # Empty object without changing identity
          for own k, v of obj
            if k != '_local'
              delete obj[k]

          # Update with store return value
          $.extend(obj, ret)

          this.runHook(afterEvent, [obj])

          return obj


exports.DebugStorage = DebugStorage
exports.HTTPStorage = HTTPStorage
exports.NullStorage = NullStorage
exports.StorageAdapter = StorageAdapter
