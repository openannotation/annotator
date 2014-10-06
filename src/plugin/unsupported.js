"use strict";

var Annotator = require('annotator'),
    _t = Annotator._t;


// Unsupported serves one very simple purpose. It will display a notification to
// the user if Annotator cannot support their current browser.
function Unsupported(reg) {
    if (!Annotator.supported()) {
        reg.notification.create(
          _t("Sorry, the Annotator does not currently support your browser!")
        );
    }
}


Annotator.Plugin.Unsupported = Unsupported;

exports.Unsupported = Unsupported;
