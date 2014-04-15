$ = require('./util').$

# Public: Provides CRUD methods for annotations which call corresponding plugin
# hooks.
class AnnotationRegistry

  # Public: create a new annotation registry object.
  #
  # core - The Annotator instance on which lifecycle events are to be raised
  # store - The Store implementation which manages persistence
  constructor: (@core, @store) ->

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
    this._cycle(obj, 'create', 'beforeAnnotationCreated', 'annotationCreated')

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
    this._cycle(obj, 'update', 'beforeAnnotationUpdated', 'annotationUpdated')

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
    this._cycle(obj, 'delete', 'beforeAnnotationDeleted', 'annotationDeleted')

  # Public: Queries the store
  #
  # query - An Object defining a query. This may be interpreted differently by
  #         different stores.
  #
  # Returns a Promise resolving to the store return value.
  query: (query) ->
    return @store.query(query)

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
      .then (annotations, meta) =>
        @core.trigger('annotationsLoaded', annotations, meta)

  # Private: cycle a store event, keeping track of the annotation object and
  # updating it as necessary.
  _cycle: (obj, storeFunc, beforeEvent, afterEvent) ->
    @core.triggerThen(beforeEvent, obj)
    .then =>
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

          @core.trigger(afterEvent, obj)

          return obj

module.exports = AnnotationRegistry
