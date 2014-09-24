# Get a unique identifier
id = (-> counter = -1; -> counter += 1)()

# Public: a no-op Storage implementation
class NullStore

  # Public: create an annotation
  #
  # annotation - An annotation Object to create.
  #
  # Returns an annotation Object.
  create: (annotation) ->
    if not annotation.id?
      annotation.id = id()
    return annotation

  # Public: update an annotation
  #
  # annotation - An annotation Object to be updated.
  #
  # Returns an annotation Object.
  update: (annotation) ->
    return annotation

  # Public: delete an annotation
  #
  # annotation - An annotation Object to be deleted.
  #
  # Returns an annotation Object.
  delete: (annotation) ->
    return annotation

  # Public: query the store for annotations
  #
  # queryObj - A query Object.
  #
  # Returns an Object representing query results.
  query: (queryObj) ->
    return {results: []}


exports.NullStore = NullStore
