Annotator = require('annotator')

# Filter is a plugin that uses the Annotator.UI.Filter component to display a
# filter bar to allow browsing and searching of annotations on the current page.
Filter = (options, filter = Annotator.UI.Filter) ->
  (reg) ->
    fl = new filter(options)

    return {
      onDestroy: -> fl.destroy()
      onAnnotationsLoaded: -> fl.updateHighlights()
      onAnnotationCreated: -> fl.updateHighlights()
      onAnnotationUpdated: -> fl.updateHighlights()
      onAnnotationDeleted: -> fl.updateHighlights()
    }


Annotator.Plugin.Filter = Filter

exports.Filter = Filter
