UI = require('../ui')
Util = require('../util')
# LegacyRanges = require('./legacyranges')

# FIXME: restore readOnly mode
#
# options: # Configuration options
#   # Start Annotator in read-only mode. No controls will be shown.
#   readOnly: false

DefaultUI = (element, options) ->
  (registry) ->
    interactionPoint = null

    adder = new UI.Adder({
      onCreate: (ann) -> registry.annotations.create(ann)
    })
    editor = new UI.Editor()
    highlighter = new UI.Highlighter(element)
    textSelector = new UI.TextSelector(element, {
      onSelection: (ranges, event) ->
        interactionPoint = Util.mousePosition(event)
        adder.onSelection(ranges, event)
    })
    viewer = new UI.Viewer(registry, element, {
      showEditButton: true
      showDeleteButton: true
    })

    return {
      destroy: ->
        adder.destroy()
        editor.destroy()
        highlighter.destroy()
        textSelector.destroy()
        viewer.destroy()

      onAnnotationsLoaded: highlighter.drawAll
      onAnnotationCreated: highlighter.draw
      onAnnotationDeleted: highlighter.undraw
      onAnnotationUpdated: highlighter.redraw

      onBeforeAnnotationCreated: (annotation) ->
        # Editor#load returns a promise that is resolved if editing completes,
        # and rejected if editing is cancelled. We return it here to "stall" the
        # annotation process until the editing is done.
        return editor.load(annotation, interactionPoint)

      onBeforeAnnotationUpdated: (annotation) ->
        return editor.load(annotation, interactionPoint)
    }

exports.DefaultUI = DefaultUI
