# Public: Adds persistence hooks for annotations.
class StorageProvider

  @configure: (registry) ->
    klass = registry.settings.store?.type

    if typeof(klass) is 'function'
      store = new klass(registry.settings.store)
    else
      store = new this(registry)

    registry['store'] ?= store

  constructor: (@registry) ->

  # Public: get an unique identifier
  id: (-> counter = 0; -> counter++)()

  # Public: create an annotation
  #
  # annotation - An annotation Object to create.
  #
  # Returns a promise of the new annotation Object.
  create: (annotation) ->
    dfd = $.Deferred()
    if not annotation.id?
      annotation.id = this.id()
    dfd.resolve(annotation)
    return dfd.promise()

  # Public: update an annotation
  #
  # annotation - An annotation Object to be updated.
  #
  # Returns a promise of the updated annotation Object.
  update: (annotation) ->
    dfd = $.Deferred()
    dfd.resolve(annotation)
    return dfd.promise()

  # Public: delete an annotation
  #
  # annotation - An annotation Object to be deleted.
  #
  # Returns a promise of the result of the delete operation.
  delete: (annotation) ->
    dfd = $.Deferred()
    dfd.resolve(annotation)
    return dfd.promise()

  # Public: query the store for annotations
  #
  # Returns a Promise resolving to the query results and query metadata.
  query: (queryObj) ->
    dfd = $.Deferred()
    dfd.resolve([], {})
    return dfd.promise()

module.exports = StorageProvider
