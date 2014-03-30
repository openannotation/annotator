StorageProvider = require './storage'
{$} = require './util'


# Public: Provides CRUD methods for annotations which call corresponding registry hooks.
class AnnotationProvider

  @configure: (registry) ->
    registry['annotations'] ?= new this(registry)
    registry.include(StorageProvider)

  constructor: (@registry) ->

  # Creates and returns a new annotation object.
  #
  # Runs the 'beforeCreateAnnotation' hook to allow the new annotation to
  # be initialized or prevented.
  #
  # Runs the 'createAnnotation' hook when the new annotation is initialized.
  #
  # Examples
  #
  #   .create({})
  #
  #   registry.on 'beforeAnnotationCreated', (annotation) ->
  #     annotation.myProperty = 'This is a custom property'
  #   registry.create({}) # Resolves to {myProperty: "This is a…"}
  #
  # Returns a Promise of an annotation Object.
  create: (obj={}) ->
    this._cycle(obj, 'create')

  # Updates an annotation.
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
      throw new TypeError("annotation must have an id for update()")
    this._cycle(obj, 'update')

  # Public: Deletes the annotation.
  #
  # annotation - An annotation Object to delete.
  #
  # Returns a Promise of an annotation Object.
  delete: (obj) ->
    if not obj.id?
      throw new TypeError("annotation must have an id for delete()")
    this._cycle(obj, 'delete')

  # Public: Queries the store
  #
  # query - An Object defining a query. This may be interpreted differently by
  #         different stores.
  #
  # Returns a Promise resolving to the store return value.
  query: (query) ->
    return @registry['store'].query(query)

  # Public: Queries the store
  #
  # query - An Object defining a query. This may be interpreted differently by
  #         different stores.
  #
  # Returns a Promise resolving to the annotations.
  load: (query) ->
    return this.query(query)

  # Private: cycle a store event, keeping track of the annotation object and
  # updating it as necessary.
  _cycle: (obj, storeFunc) ->
    safeCopy = $.extend(true, {}, obj)
    delete safeCopy._local

    @registry['store'][storeFunc](safeCopy)
      .then (ret) =>
        # Empty object without changing identity
        for own k, v of obj
          if k != '_local'
            delete obj[k]

        # Update with store return value
        $.extend(obj, ret)

        return obj 

module.exports = AnnotationProvider
