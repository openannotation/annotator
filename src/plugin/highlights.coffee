BackboneEvents = require('backbone-events-standalone')
Range = require('../range')
Util = require('../util')
$ = Util.$

# Wraps the DOM Nodes within the provided range with a highlight
# element of the specified class and returns the highlight Elements.
#
# normedRange - A NormalizedRange to be highlighted.
# cssClass - A CSS class to use for the highlight (default: 'annotator-hl')
#
# Returns an array of highlight Elements.
highlightRange = (normedRange, cssClass = 'annotator-hl') ->
  white = /^\s*$/

  hl = $("<span class='#{cssClass}'></span>")

  # Ignore text nodes that contain only whitespace characters. This prevents
  # spans being injected between elements that can only contain a restricted
  # subset of nodes such as table rows and lists. This does mean that there
  # may be the odd abandoned whitespace node in a paragraph that is skipped
  # but better than breaking table layouts.
  for node in normedRange.textNodes() when not white.test(node.nodeValue)
    $(node).wrapAll(hl).parent().show()[0]

# Public: Provide a simple way to display page annotations
class Highlights
  options:
    # Number of annotations to draw at once
    chunkSize: 10
    # Time (in ms) to pause between drawing chunks of annotations
    chunkDelay: 10

  constructor: (@element, options) ->
    @options = $.extend(true, {}, @options, options)

  configure: ({@core}) ->

  pluginInit: ->
    this.listenTo(@core, 'annotationsLoaded', this._loadAnnotations)
    this.listenTo(@core, 'annotationCreated', this._drawAnnotation)

  destroy: ->
    this.stopListening()

  _loadAnnotations: (annotations, meta) =>
    loader = (annList = []) =>
      now = annotations.splice(0, @options.chunkSize)

      this._drawAnnotations(now)

      # If there are more to do, do them after a delay
      if annList.length > 0
        setTimeout((-> loader(annList)), @options.chunkDelay)

    clone = annotations.slice()
    loader annotations

  _drawAnnotations: (annotations) ->
    for a in annotations
      this._drawAnnotation(a)

  _drawAnnotation: (annotation) ->
    # FIXME: don't use @core.wrapper here
    root = @core.wrapper[0]

    normedRanges = []
    for r in annotation.ranges
      try
        normedRanges.push(Range.sniff(r).normalize(root))
      catch e
        if e instanceof Range.RangeError
          # FIXME: This shouldn't happen here
          @core.trigger('rangeNormalizeFail', [annotation, r, e])
        else
          # Oh Javascript, why you so crap? This will lose the traceback.
          throw e

    annotation._local ?= {}
    annotation._local.highlights ?= []

    for normed in normedRanges
      $.merge annotation._local.highlights, highlightRange(normed)

    # Save the annotation data on each highlighter element.
    $(annotation._local.highlights).data('annotation', annotation)
    $(annotation._local.highlights).attr('data-annotation-id', annotation.id)

BackboneEvents.mixin(Highlights.prototype)

# This is a core plugin (registered by default with Annotator), so we don't
# register here. If you're writing a plugin of your own, please refer to a
# non-core plugin (such as Document or Store) to see how to register your plugin
# with Annotator.

module.exports = Highlights
