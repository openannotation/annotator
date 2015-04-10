"use strict";

var authorizer = require('./authorizer');
var core = require('./core');
var identifier = require('./identifier');
var notifier = require('./notifier');
var storage = require('./storage');
var util = require('./util');

var defaultUI = require('./plugin/defaultui').DefaultUI;

// Gettext
var _t = util.gettext;

// If wicked-good-xpath is available, install it. This will not overwrite any
// native XPath functionality.
var wgxpath = util.getGlobal().wgxpath;
if (typeof wgxpath !== "undefined" &&
    wgxpath !== null &&
    typeof wgxpath.install === "function") {
    wgxpath.install();
}

// Global instance registry
var instances = [];

// Annotator represents a sane default configuration of Annotator, with a
// default set of plugins and a user interface.
var Annotator = core.Annotator.extend({

    // Public: Creates an instance of the Annotator.
    //
    // NOTE: If the Annotator is not supported by the current browser it will
    // not perform any setup and simply return a basic object. This allows
    // plugins to still be loaded but will not function as expected. It is
    // reccomended to call Annotator.supported() before creating the instance or
    // using the Unsupported plugin which will notify users that the Annotator
    // will not work.
    //
    // element - A DOM Element in which to annotate.
    // options - An options Object.
    //
    // Examples
    //
    //   annotator = new Annotator(document.body)
    //
    //   // Example of checking for support.
    //   if Annotator.supported()
    //     annotator = new Annotator(document.body)
    //   else
    //     // Fallback for unsupported browsers.
    //
    // Returns a new instance of the Annotator.
    constructor: function (element, options) {
        core.Annotator.call(this);

        instances.push(this);

        // Return early if the annotator is not supported.
        if (!supported()) {
            return this;
        }

        this.setAuthorizer(authorizer.Default({}));
        this.setIdentifier(identifier.Default(null));
        this.setNotifier(notifier.Banner);
        this.setStorage(storage.NullStorage);
        this.addPlugin(defaultUI(element, options));
    },

    // Public: Destroy the current Annotator instance, unbinding all events and
    // disposing of all relevant elements.
    //
    // Returns nothing.
    destroy: function () {
        core.Annotator.prototype.destroy.call(this);

        var idx = instances.indexOf(this);
        if (idx !== -1) {
            instances.splice(idx, 1);
        }
    }
});


// Returns true if the Annotator can be used in the current environment.
function supported(details, scope) {
    if (typeof scope === 'undefined' || scope === null) {
        scope = util.getGlobal();
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

    if (errors.length > 0) {
        if (details) {
            return {
                supported: false,
                errors: errors
            };
        }
        return false;
    }
    if (details) {
        return {
            supported: true,
            errors: []
        };
    }
    return true;
}


exports.Annotator = Annotator;
exports.supported = supported;
