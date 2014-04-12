BackboneEvents = require('backbone-events-standalone')
$ = require('./util').$

# Public: Provides CRUD methods for annotations which call corresponding plugin
# hooks.
class AnnotationRegistry

  configure: (config) ->
    {@core} = config

  # Creates and returns a new annotation object.
  #
  # Runs the 'beforeCreate' hook to allow the new annotation to be initialized
  # or its creation prevented.
  #
  # Runs the 'create' hook when the new annotation has been created by the
  # store.
  #
  # Examples
  #
  #   .create({})
  #
  #   registry.on 'beforeCreate', (annotation) ->
  #     annotation.myProperty = 'This is a custom property'
  #   registry.create({}) # Resolves to {myProperty: "This is a…"}
  #
  # Returns a Promise of an annotation Object.
  create: (obj = {}) ->
    this._cycle(obj, 'create')

  # Updates an annotation.
  #
  # Runs the 'beforeUpdate' hook to allow an annotation to be modified before
  # being passed to the store, or for an update to be prevented.
  #
  # Runs the 'update' hook when the annotation has been updated by the store.
  #
  # annotation - An annotation Object to update.
  #
  # Examples
  #
  #   annotation = {tags: 'apples oranges pears'}
  #   registry.on 'beforeUpdate', (annotation) ->
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
  # Runs the 'beforeDelete' hook to allow an annotation to be modified before
  # being passed to the store, or for the a deletion to be prevented.
  #
  # Runs the 'delete' hook when the annotation has been deleted by the store.
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
    return @core.store.query(query)

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
        this.trigger('load', annotations, meta)

  # Private: cycle a store event, keeping track of the annotation object and
  # updating it as necessary.
  _cycle: (obj, storeFunc) ->
    this.trigger(
      'before' + storeFunc[0].toUpperCase() + storeFunc.slice(1),
      obj
    )
    safeCopy = $.extend(true, {}, obj)
    delete safeCopy._local

    @core.store[storeFunc](safeCopy)
      .then (ret) =>
        # Empty object without changing identity
        for own k, v of obj
          if k != '_local'
            delete obj[k]

        # Update with store return value
        $.extend(obj, ret)

        this.trigger(storeFunc, obj)

        return obj

  # Deprecated support for loading annotations directly. This is here to support
  # Annotator#loadAnnotations until it is removed.
  #
  # @slatedForDeprecation 2.1.0
  _deprecatedDirectLoad: (annotations) ->
    this.trigger('load', annotations, null) # null meta object

BackboneEvents.mixin(AnnotationRegistry.prototype)

module.exports = AnnotationRegistry
