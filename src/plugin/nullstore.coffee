Annotator = require('annotator')


# Public: The NullStore plugin is a dummy store plugin which can be used when
# debugging to provide a store that doesn't actually attempt to persist any
# changes made to annotations. All operations will succeed and all queries will
# return the empty set.
class Annotator.Plugin.NullStore
  constructor: ->
    this.idgen = (-> counter = 0; -> counter++)()

  # Public: create an annotation
  #
  # annotation - An annotation Object to create.
  #
  # Returns a pre-resolved promise object.
  create: (annotation) ->
    dfd = $.Deferred()
    if not annotation.id?
      annotation.id = this.idgen()
    dfd.resolve(annotation)
    return dfd.promise()

  # Public: update an annotation
  #
  # annotation - An annotation Object to be updated.
  #
  # Returns a pre-resolved promise object.
  update: (annotation) ->
    dfd = $.Deferred()
    dfd.resolve(annotation)
    return dfd.promise()

  # Public: delete an annotation
  #
  # annotation - An annotation Object to be deleted.
  #
  # Returns a jqXHR object.
  delete: (annotation) ->
    dfd = $.Deferred()
    dfd.resolve(annotation)
    return dfd.promise()

  # Public: query the (null) store for annotations
  #
  # Returns a Promise resolving to the query results and query metadata.
  query: (queryObj) ->
    dfd = $.Deferred()
    dfd.resolve([], {})
    return dfd.promise()


module.exports = Annotator.Plugin.NullStore