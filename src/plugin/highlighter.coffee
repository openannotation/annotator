Range = require('xpath-range').Range
Util = require('../util')
$ = Util.$
Promise = Util.Promise

# Wraps the DOM Nodes within the provided range with a highlight
# element of the specified class and returns the highlight Elements.
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
class Highlighter
  options:
    # The CSS class to apply to drawn highlights
    highlightClass: 'annotator-hl'
    # Number of annotations to draw at once
    chunkSize: 10
    # Time (in ms) to pause between drawing chunks of annotations
    chunkDelay: 10

  # Public: Create a new instance of the Highlights plugin.
  #
  # element - The root Element on which to dereference annotation ranges and
  #           draw highlights.
  # options - An options Object containing configuration options for the plugin.
  #           See `Highlights.options` for available options.
  #
  # Returns a new plugin instance.
  constructor: (@element, options) ->
    @options = $.extend(true, {}, @options, options)


  destroy: ->
    $(@element).find(".#{@options.highlightClass}").each (i, el) ->
      $(el).contents().insertBefore(el)
      $(el).remove()

  # Public: Draw highlights for all the given annotations
  #
  # annotations - An Array of annotation Objects for which to draw highlights.
  #
  # Returns nothing.
  drawAll: (annotations) =>
    return new Promise((resolve, reject) =>
      highlights = []

      loader = (annList = []) =>
        now = annList.splice(0, @options.chunkSize)

        for a in now
          highlights = highlights.concat(this.draw(a))

        # If there are more to do, do them after a delay
        if annList.length > 0
          setTimeout((-> loader(annList)), @options.chunkDelay)
        else
          resolve(highlights)

      clone = annotations.slice()
      loader(clone)
    )

  # Public: Draw highlights for the annotation.
  #
  # annotation - An annotation Object for which to draw highlights.
  #
  # Returns an Array of drawn highlight elements.
  draw: (annotation) =>
    normedRanges = []
    for r in annotation.ranges
      try
        normedRanges.push(Range.sniff(r).normalize(@element))
      catch e
        if e instanceof Range.RangeError
          # FIXME: This shouldn't happen here
          @core.trigger('rangeNormalizeFail', annotation, r, e)
        else
          # Oh Javascript, why you so crap? This will lose the traceback.
          throw e

    annotation._local ?= {}
    annotation._local.highlights ?= []

    for normed in normedRanges
      $.merge(
        annotation._local.highlights,
        highlightRange(normed, @options.highlightClass)
      )

    # Save the annotation data on each highlighter element.
    $(annotation._local.highlights).data('annotation', annotation)
    # Add a data attribute for annotation id if the annotation has one
    if annotation.id?
      $(annotation._local.highlights).attr('data-annotation-id', annotation.id)

    return annotation._local.highlights

  # Public: Remove the drawn highlights for the given annotation.
  #
  # annotation - An annotation Object for which to purge highlights.
  #
  # Returns nothing.
  undraw: (annotation) ->
    if annotation._local?.highlights?
      for h in annotation._local.highlights when h.parentNode?
        $(h).replaceWith(h.childNodes)
      delete annotation._local.highlights

  # Public: Redraw the highlights for the given annotation.
  #
  # annotation - An annotation Object for which to redraw highlights.
  #
  # Returns nothing.
  redraw: (annotation) =>
    this.undraw(annotation)
    this.draw(annotation)



# This is a core plugin (registered by default with Annotator), so we don't
# register here. If you're writing a plugin of your own, please refer to a
# non-core plugin (such as Document or Store) to see how to register your plugin
# with Annotator.

module.exports = Highlighter
