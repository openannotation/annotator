"use strict";

var Annotator = require('annotator-plugintools').Annotator,
    _t = Annotator._t;


// Unsupported serves one very simple purpose. It will display a notification to
// the user if Annotator cannot support their current browser.
function Unsupported(reg) {
    var details = Annotator.supported(true);
    if (!details.supported) {
        reg.notifier.show(
          _t("Sorry, the Annotator does not currently support your browser!") +
          " " +
          _t("Errors: ") +
          details.errors.join(", ")
        );
    }
}


Annotator.Plugin.Unsupported = Unsupported;

exports.Unsupported = Unsupported;
