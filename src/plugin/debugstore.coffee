Annotator = require('annotator')

uuid = (-> counter = -1; -> counter += 1)()

trace = (action, annotation) ->
  console.debug("DebugStore: #{action}", JSON.parse(JSON.stringify(annotation)))


# Public: The DebugStore plugin can be used to print details of the annotation
# persistence processes to the console when developing other parts of Annotator.
DebugStore = ->

  create: (annotation) ->
    annotation.id = uuid()
    trace('create', annotation)
    return annotation

  update: (annotation) ->
    trace('update', annotation)
    return annotation

  delete: (annotation) ->
    trace('destroy', annotation)
    return annotation

  query: (queryObj) ->
    trace('query', queryObj)
    return {results: [], metadata: {total: 0}}

  setHeader: (key, value) ->
    trace('setHeader', "#{key}=#{value}")


Annotator.Plugin.DebugStore = DebugStore

exports.DebugStore = DebugStore
