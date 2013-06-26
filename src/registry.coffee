error = (obj, message) ->
  dfd = new $.Deferred()
  dfd.reject(obj, message)
  return dfd.promise()

class Annotator.Registry extends Evented
  constructor: (@store) ->

  # Public: Creates and returns a new annotation object.
  #
  # Publishes the 'beforeAnnotationCreated' event to allow the new annotation to
  # be modified before being passed to the store.
  #
  # Publishes the 'annotationCreated' event when the new annotation is returned
  # from the store.
  #
  # Examples
  #
  #   registry.create({})
  #
  #   registry.on 'beforeAnnotationCreated', (annotation) ->
  #     annotation.myProperty = 'This is a custom property'
  #   registry.create({}) # Resolves to {myProperty: "This is a…"}
  #
  # Returns a Promise of an annotation Object.
  create: (obj) ->
    obj = this._preflight(obj)

    this.publish('beforeAnnotationCreated', [obj])
    @store.create(obj)
      # if not data.id?
      #   console.warn Annotator._t("Warning: No ID returned from server for annotation "), annotation
      .then (ret) =>
        this.publish('annotationCreated', [ret])
        return ret

  # Public: Updates an already registered annotation.
  #
  # Publishes the 'beforeAnnotationUpdated' and 'annotationUpdated' events.
  # Listeners wishing to modify an updated annotation should subscribe to
  # 'beforeAnnotationUpdated' while listeners storing annotations should
  # subscribe to 'annotationUpdated'.
  #
  # annotation - An annotation Object to update.
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
      return error(obj, "annotation must have an id for update()")

    obj = this._preflight(obj)

    this.publish('beforeAnnotationUpdated', [obj])
    @store.update(obj)
      .then (ret) =>
        this.publish('annotationUpdated', [ret])
        return ret

  # Public: Deletes the annotation.
  #
  # Publishes the 'beforeAnnotationDeleted' event before the request for
  # deletion is passed to the store, and the 'annotationDeleted' event on
  # completion.
  #
  # annotation - An annotation Object to delete.
  #
  # Returns a Promise resolving to the store return value.
  delete: (obj) ->
    if not obj.id?
      return error(obj, "annotation must have an id for delete()")

    obj = this._preflight(obj)

    this.publish('beforeAnnotationDeleted', [obj])
    @store.delete(obj)
      .then (ret) =>
        this.publish('annotationDeleted', [ret])
        return ret

  # Public: Queries the store
  #
  # query - An Object defining a query. This may be interpreted differently by
  #         different stores.
  #
  # Returns a Promise resolving to the store return value.
  query: (query) ->
    return @store.query(query)

  # Public: Load annotations from a query to the backend store.
  #
  # query - An Object defining a query. This may be interpreted differently by
  #         different stores.
  #
  # Returns a Promise resolving to the store return value.
  load: (query) ->
    return this.query(query)

  _preflight: (obj) ->
    delete obj._localData
    return obj
