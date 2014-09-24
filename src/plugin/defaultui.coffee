UI = require('../ui')
# LegacyRanges = require('./legacyranges')
# Editor = require('./editor')

# FIXME: restore readOnly mode
#
# options: # Configuration options
#   # Start Annotator in read-only mode. No controls will be shown.
#   readOnly: false

DefaultUI = (element, options) ->
  (registry) ->
    adder = new UI.Adder(registry)
    highlighter = new UI.Highlighter(element)
    textSelector = new UI.TextSelector(element, {
      onSelection: adder.onSelection
    })

    return {
      destroy: ->
        adder.destroy()
        highlighter.destroy()
        textSelector.destroy()
      onAnnotationsLoaded: highlighter.drawAll
      onAnnotationCreated: highlighter.draw
      onAnnotationDeleted: highlighter.undraw
      onAnnotationUpdated: highlighter.redraw
    }

exports.DefaultUI = DefaultUI
