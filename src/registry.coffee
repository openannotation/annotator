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
    this._cycle(obj, 'create', 'annotationCreated')
    # if not data.id?
    #   console.warn Annotator._t("Warning: No ID returned from server for annotation "), annotation


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

    this._cycle(obj, 'update', 'annotationUpdated')

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

    this._cycle(obj, 'delete', 'annotationDeleted')

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

  # Private: cycle a store event, keeping track of the annotation object and
  # updating it as necessary.
  _cycle: (obj, storeFunc, event) ->
    this.publish('before' + event[0].toUpperCase() + event.slice(1), [obj])

    safeCopy = $.extend(true, {}, obj)
    delete safeCopy._local

    @store[storeFunc](safeCopy)
      .then (ret) =>
        # Empty object without changing identity
        for own k, v of obj
          if k != '_local'
            delete obj[k]

        # Update with store return value
        $.extend(obj, ret)

        this.publish(event, [obj])
        return obj
