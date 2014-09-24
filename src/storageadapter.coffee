{$, Promise} = require('./util')

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

exports.StorageAdapter = StorageAdapter
