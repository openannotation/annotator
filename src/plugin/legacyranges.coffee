BackboneEvents = require('backbone-events-standalone')
Range = require('xpath-range').Range
Util = require('../util')
$ = Util.$

# Public: Provide support to annotate text selections in HTML documents
class LegacyRanges

  constructor: (element) ->
    @element = element

  configure: ({@core}) ->

  pluginInit: ->
    this.listenTo @core, 'rawSelection', (raw) =>
      if raw.type is "text ranges"
        @core.trigger "selection", @createSkeleton raw.ranges

  destroy: ->
    this.stopListening()

  # Public: Create a skeleton for an annotation, based on a list of ranges.
  #
  # ranges - An Array of NormalizedRanges to use when creating the annotation.
  #
  # Returns the data structure which should be used to init the annotation.
  createSkeleton: (ranges) ->
    annotation = {
      quote: [],
      ranges: [],
    }

    for normed in ranges
      annotation.quote.push($.trim(normed.text()))
      annotation.ranges.push(
        normed.serialize(@element, '.annotator-hl')
      )

    # Join all the quotes into one string.
    annotation.quote = annotation.quote.join(' / ')

    return annotation

BackboneEvents.mixin(LegacyRanges.prototype)

# This is a core plugin (registered by default with Annotator), so we don't
# register here. If you're writing a plugin of your own, please refer to a
# non-core plugin (such as Document or Store) to see how to register your plugin
# with Annotator.

module.exports = LegacyRanges
