Annotator = require('annotator')
$ = Annotator.Util.$
_t = Annotator._t


# Unsupported serves one very simple purpose. It will display a notification to
# the user if Annotator cannot support their current browser.
Unsupported = (reg) ->
  unless Annotator.supported()
    reg.notification.create(
      _t("Sorry, the Annotator does not currently support your browser!")
    )


Annotator.Plugin.Unsupported = Unsupported

exports.Unsupported = Unsupported
