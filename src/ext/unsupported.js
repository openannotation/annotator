"use strict";

var annotator = require('annotator');
var _t = annotator.util.gettext;

/**
 * function:: checkSupport([scope=window])
 *
 * Examines `scope` (by default the global window object) to determine if
 * Annotator can be used in this environment.
 *
 * :returns Object:
 *   - `supported`: Boolean, whether Annotator can be used in `scope`.
 *   - `details`: Array of String reasons why Annotator cannot be used.
 */
function checkSupport(scope) {
    if (typeof scope === 'undefined' || scope === null) {
        scope = annotator.util.getGlobal();
    }

    var errors = [];

    if (typeof scope.getSelection !== 'function') {
        errors.push(_t("current scope lacks an implementation of the W3C " +
                       "Range API"));
    }

    // We require a working JSON implementation.
    if (typeof scope.JSON === 'undefined' ||
        typeof scope.JSON.parse !== 'function' ||
        typeof scope.JSON.stringify !== 'function') {
        errors.push(_t("current scope lacks a working JSON implementation"));
    }

    return {
        supported: errors.length === 0,
        errors: errors
    };
}


// unsupported serves one very simple purpose. It will display a notification to
// the user if Annotator cannot support their current browser.
function unsupported() {
    // Reference as exports.checkSupport so that we can stub it for testing.
    var result = exports.checkSupport();

    function notifyUser(app) {
        if (result.supported) {
            return;
        }
        var msg;
        msg = _t("Sorry, Annotator does not currently support your browser! ");
        msg += _t("Errors: ");
        msg += result.errors.join(", ");
        app.notify(msg);
    }

    return {
        start: notifyUser
    };
}


annotator.ext.unsupported = unsupported;

exports.checkSupport = checkSupport;
exports.unsupported = unsupported;
