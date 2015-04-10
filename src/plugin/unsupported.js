"use strict";

var annotator = require('annotator');
var _t = annotator.util.gettext;


// Unsupported serves one very simple purpose. It will display a notification to
// the user if Annotator cannot support their current browser.
function Unsupported(reg) {
    var details = annotator.supported(true);
    if (!details.supported) {
        reg.notifier.show(
          _t("Sorry, the Annotator does not currently support your browser!") +
          " " +
          _t("Errors: ") +
          details.errors.join(", ")
        );
    }
}


annotator.plugin.Unsupported = Unsupported;

exports.Unsupported = Unsupported;
