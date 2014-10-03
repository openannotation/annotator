UI = require('../ui')
Util = require('../util')


# trim strips whitespace from either end of a string.
#
# This usually exists in native code, but not in IE8.
trim = (s) ->
  if String.prototype.trim?
    return String.prototype.trim.call(s)
  else
    return s.replace(/^[\s\xA0]+|[\s\xA0]+$/g, '')


# Helper function to construct an annotation from a list of selected ranges
annotationFactory = (contextEl, ignoreSelector) ->
  (ranges) ->
    {
      quote: (trim(r.text()) for r in ranges).join(' / ')
      ranges: (r.serialize(contextEl, ignoreSelector) for r in ranges)
    }


# maxZIndex returns the maximum z-index of all elements in the provided set.
maxZIndex = (elements) ->
  all = for el in elements
    $el = Util.$(el)
    if $el.css('position') == 'static'
      -1
    else
      # Use parseFloat since we may get scientific notation for large values.
      parseFloat($el.css('z-index')) or -1
  Math.max.apply(Math, all)


# Helper function to inject CSS into the page that ensures Annotator elements
# are displayed with the highest z-index.
injectDynamicStyle = ->
  Util.$('#annotator-dynamic-style').remove()

  notclasses = ['adder', 'outer', 'notice', 'filter']
  sel = '*' + (":not(.annotator-#{x})" for x in notclasses).join('')

  # use the maximum z-index in the page
  max = maxZIndex(Util.$(document.body).find(sel).get())

  # but don't go smaller than 1010, because this isn't bulletproof --
  # dynamic elements in the page (notifications, dialogs, etc.) may well
  # have high z-indices that we can't catch using the above method.
  max = Math.max(max, 1000)

  rules = [
    ".annotator-adder, .annotator-outer, .annotator-notice {"
    "  z-index: #{max + 20};"
    "}"
    ".annotator-filter {"
    "  z-index: #{max + 10};"
    "}"
  ].join("\n")

  style = Util.$('<style>' + rules + '</style>')
    .attr('id', 'annotator-dynamic-style')
    .attr('type', 'text/css')
    .appendTo('head')


# Helper function to remove dynamic stylesheets
removeDynamicStyle = ->
  Util.$('#annotator-dynamic-style').remove()


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

    injectDynamicStyle()

    return {
      onDestroy: ->
        adder.destroy()
        editor.destroy()
        highlighter.destroy()
        textSelector.destroy()
        viewer.destroy()
        removeDynamicStyle()

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
