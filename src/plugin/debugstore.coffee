Annotator = require('annotator')
$ = Annotator.Util.$


uuid = (-> counter = -1; -> counter += 1)()

log = (args...) ->
  console.debug("DebugStore", args...)

perform = (action, annotation) ->
  log(action, JSON.parse(JSON.stringify(annotation)))
  dfd = $.Deferred()
  dfd.resolve(annotation)
  return dfd.promise()

# Public: The DebugStore plugin can be used to print details of the annotation
# persistence processes to the console when developing other parts of Annotator.
class DebugStore

  create: (annotation) ->
    annotation.id = uuid()
    return perform('create', annotation)

  update: (annotation) ->
    return perform('update', annotation)

  delete: (annotation) ->
    return perform('destroy', annotation)

  query: (queryObj) ->
    dfd = $.Deferred()
    perform('query', queryObj)
    dfd.resolve([], {total: 0})
    return dfd.promise()

  setHeader: (key, value) ->
    log("would set header '#{key}'='#{value}'")


Annotator.Plugin.register('DebugStore', DebugStore)

module.exports = DebugStore
