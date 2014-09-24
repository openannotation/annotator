UI = require('../ui')
# LegacyRanges = require('./legacyranges')
# Editor = require('./editor')
# Highlighter = require('./highlighter')

# FIXME: restore readOnly mode
#
# options: # Configuration options
#   # Start Annotator in read-only mode. No controls will be shown.
#   readOnly: false

DefaultUI = (element, options) ->
  (registry) ->
    adder = new UI.Adder(registry)
    textSelector = new UI.TextSelector(element, {
      onSelection: adder.onSelection
    })

    return {
    }

exports.DefaultUI = DefaultUI
