# Annotator plugin that handles storing annotations locally. It also detects
# the browsers connectivity allowing you to sync annotations with an external
# persistant store.
#  
# As well as the online() and offline() callbacks that can be provided when
# the plugin is initialised "online" and "offline" events are also triggered.
#
# Also triggered are the "beforeAnnotationLoaded" and "annotationLoaded"
# events. These are fired when the annotions are extracted from localStorage.
# "beforeAnnotationLoaded" should always be used to modify the annotation and
# "annotationLoaded" for anything that needs to happen afterward.
#
# Examples
#
#   annotator 'addPlugin', 'Offline',
#     online: (plugin) ->
#       startServerPoll()
#     offline: (plugin) ->
#       cancelServerPoll()
#
# Returns a new instance of the Elasticsearch plugin.
Annotator.Plugin.Elasticsearch = class Elasticsearch extends Annotator.Plugin
  # Export Annotator properties into the local scope.
  _t = Annotator._t
  jQuery = Annotator.$

  # Prefix for all annotation keys assigned to the store.
  @ANNOTATION_PREFIX = "annotation_"

  # Public: Creates a reasonably unique identifier based on the current time
  # and a randomly generated value. This is really only suitable for local
  # deployments, if you're going to be using these ids to persist annotations
  # elsewhere it would be worth assigning a RFC4122 compatible uuid using the
  # setAnnotationData() option.
  #
  # Examples
  #
  #   Elasticsearch.uuid() #=> "92992580798454581328033163230"
  #
  # Returns a randomly generated string.
  @uuid = -> ("" + Math.random() + new Date().getTime()).slice(2)

  # Default event listeners.
  events:
    "annotationCreated": "_onAnnotationCreated"
    "annotationUpdated": "_onAnnotationUpdated"
    "annotationDeleted": "_onAnnotationDeleted"

  # Default options for the plugin.
  options:
    # Creates a unique key for the annotation to be stored against. This uses
    # the annotations "id" property if it has one, otherwise it will assign it
    # a randomly generated key.
    #
    # annotation - An annotation object.
    #
    # Examples
    #
    #   annotation = {id: "a-unique-id"}
    #   @getUniqueKey(annotation) #=> "a-unique-id"
    #
    # Returns a unique identifier for the annotation.
    getUniqueKey: (annotation) ->
      annotation.id = Elasticsearch.uuid() unless annotation.id
      annotation.id

    # Checks to see if the annotation should be loaded into this page. If
    # the function returns true then it will be loaded. By default it will
    # always return true. This can be overrided in the options.
    #
    # annotation - An annotation object.
    #
    # Examples
    #
    #   @shouldLoadAnnotation(annotation) #=> true
    #
    # Returns true or false.
    shouldLoadAnnotation: (annotation) -> true

  # Creates a new instance of the plugin and initialises instance variables.
  #
  # element - The root annotator element.
  # options - An object literal of options.
  #           online:            Function that is called when the plugin goes
  #                              online. Recieves the plugin object as an
  #                              argument.
  #           offline:           Function that is called when the plugin goes
  #                              offline. Recieves the plugin object as an
  #                              argument.
  #           getUniqueKey:      Function that accepts an annotation to return
  #                              a unique value. By default it returns the id.
  #           setAnnotationData: Accepts a newly created annotation for
  #                              modification such as adding properties.
  #           shouldLoadAnnotation: Function that should return if the
  #                                 annotation should be loaded in this page.
  #
  # Returns nothing.
  constructor: (elements,options) ->
    super
    @url = options.url
    @index = options.index

    @store = new Elasticsearch.Store(@url, @index)
    @cache = {}
    handlers =
      online: "online"
      offline: "offline"
      beforeAnnotationLoaded:  "setAnnotationData"
      beforeAnnotationCreated: "setAnnotationData"

    for own event, handler of handlers
      if typeof @options[handler] is "function"
        @on(event, jQuery.proxy @options, handler)

  # Internal: Initialises the plugin, called by the Annotator object once a
  # new instance of the object has been created and the @annotator property
  # attached.
  #
  # Returns nothing.
  pluginInit: ->
    return unless Annotator.supported()

    @loadAnnotationsFromStore()
    if @isOnline() then @online() else @offline()
    jQuery(window).bind(online: @_onOnline, offline: @_onOffline)

  # Public: Returns an object of loaded annotations indexed by unique key.
  #
  # Examples
  #
  #   plugin.annotations() #=> {1: {id: 1, text: "Test"}, 2: {id: 2, ...}}
  #
  # Returns an object.
  annotations: -> @cache

  # Public: Publishes the "online" event on the plugin. All registered
  # subscribers recieve the plugin instance as the first argument.
  #
  # Examples
  #
  #   plugin.on "online", -> alert("We're now online!")
  #   plugin.online() # Alert box is displayed.
  #
  # Returns itself.
  online: ->
    @publish "online", [this]
    this

  # Public: Publishes the "offline" event on the plugin. All registered
  # subscribers recieve the plugin instance as the first argument.
  #
  # Examples
  #
  #   plugin.on "offline", -> alert("We're now offline!")
  #   plugin.offline() # Alert box is displayed.
  #
  # Returns itself.
  offline: ->
    @publish "offline", [this]
    this

  # Public: Checks to see if the browser currently has a network connection.
  #
  # Examples
  #
  #   if plugin.isOnline() then backupData()
  #
  # Returns true if the browser has connectivitiy.
  isOnline: -> window.navigator.onLine

  # Public: Loads all stored annotations into the page. This should generally
  # only be called on page load.
  #
  # Examples
  #
  #   offline.loadAnnotationsFromStore()
  #
  # Returns itself.
  loadAnnotationsFromStore: ->
    current = []
    annotations = @store.all(Elasticsearch.ANNOTATION_PREFIX)
    for annotation in annotations when @options.shouldLoadAnnotation(annotation)
      # beforeAnnotationLoaded allows the annotation data to be manipulated
      # before it is loaded into Annotator.
      @publish("beforeAnnotationLoaded", [annotation, this])
      @publish("annotationLoaded", [annotation, this])
      @cache[@keyForAnnotation(annotation)] = annotation
      current.push(annotation)
    @annotator.loadAnnotations(current) if current.length
    this

  # Public: Adds an annotation to the store, also adds it to the current
  # page if needed.
  #
  # annotation - An annotation object to save.
  # options    - An object of method options.
  #              silent: If true prevents the annotator from firing the
  #                      "annotationCreated" event.
  #
  # Examples
  #
  #   getAnnotationFromServer (ann) ->
  #     offline.addAnnotation(ann)
  #
  # Returns itself.
  addAnnotation: (annotation, options={}) ->
    isLoaded = @cache[@options.getUniqueKey(annotation)]
    if not isLoaded and @options.shouldLoadAnnotation(annotation)
      @annotator.setupAnnotation(annotation, options.silent)
    else
      @updateStoredAnnotation(annotation)
    this

  # Public: Removes an annotation from the store, also removes it from the
  # current page if needed.
  #
  # annotation - An annotation object to remove.
  #
  # Examples
  #
  #   getAnnotationFromServer (ann) ->
  #     offline.addAnnotation(ann)
  #
  # Returns itself.
  removeAnnotation: (annotation) ->
    if @options.shouldLoadAnnotation(annotation)
      @annotator.deleteAnnotation(annotation)
    else
      @removeStoredAnnotation(annotation)
    this

  # Public: Updates the locally stored copy of the annotation.
  #
  # annotation - An annotation object.
  #
  # Examples
  #
  #   onAnnotationUpdated = (ann) ->
  #     store.updateAnnotation(ann)
  #
  # Returns itself.
  updateStoredAnnotation: (annotation) ->
    id  = @keyForAnnotation(annotation)
    key = @keyForStore(annotation)

    local = @cache[id]
    if local
      jQuery.extend(local, annotation)
    else
      local = @cache[id] = annotation

    storable = jQuery.extend({}, local)
    delete storable.highlights

    @store.set(key, storable)
    this

  # Public: Removes the annotation from local storage.
  #
  # annotation - An annotation object.
  #
  # Examples
  #
  #   onAnnotationDeleted = (ann) ->
  #     store.removeAnnotation(ann)
  #
  # Returns itself.
  removeStoredAnnotation: (annotation) ->
    id  = @keyForAnnotation(annotation)
    key = @keyForStore(annotation)
    @store.remove(key)
    delete @cache[id]
    this

  # Internal: Retrieves a key for an annotation. This can be customised using
  # the getUniqueKey() option. By default it will use the "id" property on the
  # annotation.
  #
  # annotation - An annotation object.
  #
  # Examples
  #
  #   key = @keyForAnnotation(annotation)=
  #
  # Returns a unique key for the annotation.
  keyForAnnotation: (annotation) ->
    @options.getUniqueKey.call(this, annotation, this)

  # Internal: Retrieves a key for the local storage.
  #
  # annotation - An annotation object.
  #
  # Examples
  #
  #   key = @keyForStore(annotation)
  #   store.set(key, annotation)
  #
  # Returns a key to be used to store the annotation.
  keyForStore: (annotation) ->
    Elasticsearch.ANNOTATION_PREFIX + @keyForAnnotation(annotation)

  # Event callback for the "online" window event.
  #
  # event - A jQuery event object.
  #
  # Returns nothing.
  _onOnline:  (event) => @online()

  # Event callback for the "offline" window event.
  #
  # event - A jQuery event object.
  #
  # Returns nothing.
  _onOffline: (event) => @offline()

  # Event callback for the "annotationCreated" event.
  #
  # annotation - An annotation object.
  #
  # Returns nothing.
  _onAnnotationCreated: (annotation) ->
    @updateStoredAnnotation(annotation)

  # Event callback for the "annotationUpdated" event.
  #
  # annotation - An annotation object.
  #
  # Returns nothing.
  _onAnnotationUpdated: (annotation) ->
    @updateStoredAnnotation(annotation)

  # Event callback for the "annotationDeleted" event.
  #
  # annotation - An annotation object.
  #
  # Returns nothing.
  _onAnnotationDeleted: (annotation) ->
    @removeStoredAnnotation(annotation)
