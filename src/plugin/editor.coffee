Annotator = require('annotator')

# Editor is a plugin that uses the Annotator.UI.Editor component to display an
# editor widget allowing the user to provide a note (and other data) before an
# annotation is created or updated.
Editor = (options, editor = Annotator.UI.Editor) ->
  (reg) ->
    ed = new editor(options)

    return {
      onDestroy: ->
        ed.destroy()

      onBeforeAnnotationCreated: (annotation) ->
        return ed.load(annotation)

      onBeforeAnnotationUpdated: (annotation) ->
        return ed.load(annotation)
    }


Annotator.Plugin.Editor = Editor

exports.Editor = Editor
