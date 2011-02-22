class Annotator.Plugin.Store extends Annotator.Plugin
  events:
    'annotationCreated': 'annotationCreated'
    'annotationDeleted': 'annotationDeleted'
    'annotationUpdated': 'annotationUpdated'

  options:
    prefix: '/store'

    autoFetch: true
    annotationData: {}

    # If loadFromSearch is set, then we load the first batch of
    # annotations from the 'search' URL as set in `options.urls`
    # instead of the registry path 'prefix/read'.
    #
    #     loadFromSearch: {
    #       'limit': 0,
    #       'all_fields': 1
    #       'uri': 'http://this/document/only'
    #     }
    loadFromSearch: false

    urls:
      create:  '/annotations'     # POST
      read:    '/annotations/:id' # GET
      update:  '/annotations/:id' # PUT (since idempotent)
      destroy: '/annotations/:id' # DELETE
      search:  '/search'

  constructor: (element, options) ->
    super
    this.addEvents()
    @annotations = []

  pluginInit: ->
    return unless Annotator.supported()

    getAnnotations = =>
      if @options.loadFromSearch
        this.loadAnnotationsFromSearch(@options.loadFromSearch)
      else
        this.loadAnnotations()

    auth = $(@element).data('annotator:auth')

    if auth
      auth.withToken(getAnnotations)
    else
      getAnnotations()

  annotationCreated: (e, annotation) ->
    # Pre-register the annotation so as to save the list of highlight
    # elements.
    if annotation not in @annotations
      this.registerAnnotation(annotation)

      this._apiRequest('create', annotation, (data) =>
        # Update with (e.g.) ID from server.
        if not data.id?
          console.warn "Warning: No ID returned from server for annotation ", annotation
        this.updateAnnotation annotation, data
      )
    else
      # This is called to update annotations created at load time with
      # the highlight elements created by Annotator.
      this.updateAnnotation annotation, {}

  annotationDeleted: (e, annotation) ->
    if annotation in this.annotations
      this._apiRequest 'destroy', annotation, (() => this.unregisterAnnotation(annotation))

  annotationUpdated: (e, annotation) ->
    if annotation in this.annotations
      this._apiRequest 'update', annotation, (() => this.updateAnnotation(annotation))

  # NB: registerAnnotation and unregisterAnnotation do no error-checking/
  # duplication avoidance of their own. Use with care.
  registerAnnotation: (annotation) ->
    @annotations.push(annotation)

  unregisterAnnotation: (annotation) ->
    @annotations.splice(@annotations.indexOf(annotation), 1)

  updateAnnotation: (annotation, data) ->
    if annotation not in this.annotations
      console.error "Trying to update unregistered annotation!"
    else
      $.extend(annotation, data)

    # Update the elements with our copies of the annotation objects (e.g.
    # with ids from the server).
    $(annotation.highlights).data('annotation', annotation)

  loadAnnotations: () ->
    this._apiRequest('read', null, (data) =>
      @annotations = data.slice() # Clone array
      @annotator.loadAnnotations(data)
    )

  loadAnnotationsFromSearch: (searchOptions) ->
    this._apiRequest('search', searchOptions, (data) =>
      @annotations = data.results.slice() # Clone array
      @annotator.loadAnnotations(data.results)
    )

  ##
  # Dump an array of serialized annotations
  dumpAnnotations: ->
    (JSON.parse(this._dataFor(ann)) for ann in @annotations)

  ##
  # Make a request to the Annotator Store API
  #
  # @private
  _apiRequest: (action, obj, onSuccess) ->
    id = obj && obj.id

    opts = {
      url:        this._urlFor(action, id),
      type:       this._methodFor(action),
      beforeSend: this._onBeforeSend,
      dataType:   "json",
      success:    (onSuccess or ->),
      error:      this._onError
    }

    # Don't JSONify obj if making search request.
    if action is "search"
      opts = $.extend(opts, {data: obj})
    else
      opts = $.extend(opts, {
        data:        obj && this._dataFor(obj)
        contentType: "application/json; charset=utf-8"
      })

    request = $.ajax(opts)
    request._id = id
    request._action = action

  _urlFor: (action, id) ->
    replaceWith = if id? then '/' + id else ''

    url = @options.prefix or '/'
    url += @options.urls[action]
    url = url.replace(/\/:id/, replaceWith)

    url

  _methodFor: (action) ->
    table = {
      'create':  'POST'
      'read':    'GET'
      'update':  'PUT'
      'destroy': 'DELETE'
      'search':  'GET'
    }

    table[action]

  _actionFor: (method) ->
    for action, currentMethod in @_methodMap
      return action if method == currentMethod

  _dataFor: (annotation) ->
    # Store a reference to the highlights array. We can't serialize
    # a list of HTMLElement objects.
    highlights = annotation.highlights

    delete annotation.highlights

    # Preload with extra data.
    $.extend(annotation, @options.annotationData)
    data = JSON.stringify(annotation)

    # Restore the highlights array.
    annotation.highlights = highlights

    data

  # Set request headers before send
  _onBeforeSend: (xhr) =>
    headers = $(@element).data('annotator:headers')
    if headers
      for key, val of headers
        xhr.setRequestHeader(key, val)

  _onError: (xhr, text, error) =>
    action  = xhr._action
    message = "Sorry we could not #{action} this annotation"

    if xhr._action == 'store' || (xhr._action == 'read' && !xhr._id)
      message = "Sorry we could not #{action} the annotations from the store"

    switch xhr.status
      when 401 then message = "Sorry you are not allowed to #{action} this annotation"
      when 404 then message = "Sorry we could not connect to the annotations store"
      when 500 then message = "Sorry something went wrong with the annotation store"

    Annotator.showNotification message

    console.error "API request failed: '#{xhr.status}'"
