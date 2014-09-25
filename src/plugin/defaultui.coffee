UI = require('../ui')
Util = require('../util')
# LegacyRanges = require('./legacyranges')


# Polyfill String#trim() for IE8
if not String::trim?
  String::trim = ->
    this.replace(/^[\s\xA0]+|[\s\xA0]+$/g, '')

# Helper function to construct an annotation from a list of selected ranges
annotationFactory = (contextEl, ignoreSelector) ->
  (ranges) ->
    {
      quote: (r.text().trim() for r in ranges).join(' / ')
      ranges: (r.serialize(contextEl, ignoreSelector) for r in ranges)
    }


# DefaultUI is a function that can be used to construct a plugin that will
# provide Annotator's default user interface.
#
# element - The DOM element which you want to be able to annotate.
# options - An Object of options.
#
# Examples
#
#    ann = new AnnotatorCore()
#    ann.addPlugin(DefaultUI(document.body, {}))
#
# Returns an Annotator plugin.
DefaultUI = (element, options) ->
  # FIXME: restore readOnly mode
  #
  # options: # Configuration options
  #   # Start Annotator in read-only mode. No controls will be shown.
  #   readOnly: false
  #

  (registry) ->
    # Local helpers
    makeAnnotation = annotationFactory(element, '.annotator-hl')

    # Shared user interface state
    interactionPoint = null

    # UI components
    adder = new UI.Adder()
    editor = new UI.Editor()
    highlighter = new UI.Highlighter(element)
    textSelector = new UI.TextSelector(element)
    viewer = new UI.Viewer({
      showEditButton: true
      showDeleteButton: true
      onEdit: (ann) -> registry.annotations.update(ann)
      onDelete: (ann) -> registry.annotations.delete(ann)
      autoViewHighlights: element
    })

    adder.onCreate = (ann, event) ->
      registry.annotations.create(ann)

    textSelector.onSelection = (ranges, event) ->
      if ranges.length > 0
        annotation = makeAnnotation(ranges)
        interactionPoint = Util.mousePosition(event)
        adder.load(annotation, interactionPoint)
      else
        adder.hide()

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
