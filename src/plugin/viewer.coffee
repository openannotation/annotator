Annotator = require('annotator')

# Viewer is a plugin that uses the Annotator.UI.Viewer component to display an
# viewer widget in response to some viewer action (such as mousing over an
# annotator highlight element).
Viewer = (options, viewer = Annotator.UI.Viewer) ->
  (reg) ->
    # Set default handlers for what happens when the user clicks the edit and
    # delete buttons:
    if typeof options.onEdit == 'undefined'
      options.onEdit = (annotation) -> reg.annotations.update(annotation)

    if typeof options.onDelete == 'undefined'
      options.onDelete = (annotation) -> reg.annotations.delete(annotation)

    vw = new viewer(options)

    return {
      destroy: -> vw.destroy()
    }


Annotator.Plugin.Viewer = Viewer

exports.Viewer = Viewer
