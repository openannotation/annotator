Annotator = require('annotator')


# Highlighter is a simple plugin that uses the Annotator.UI.Highlighter
# component to draw/undraw highlights automatically when annotations are created
# and removed.
Highlighter = (element, options, highlighter = Annotator.UI.Highlighter) ->
  (reg) ->
    hl = new highlighter(element, options)

    return {
      onDestroy: ->
        hl.destroy()
      onAnnotationsLoaded: hl.drawAll
      onAnnotationCreated: hl.draw
      onAnnotationDeleted: hl.undraw
      onAnnotationUpdated: hl.redraw
    }


Annotator.Plugin.Highlighter = Highlighter

exports.Highlighter = Highlighter
