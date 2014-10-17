"use strict";

var Authorizer = require('./authorizer'),
    Core = require('./core'),
    Identifier = require('./identifier'),
    Notifier = require('./notifier'),
    Storage = require('./storage'),
    Util = require('./util');

var defaultUI = require('./plugin/defaultui').DefaultUI;

// Store a reference to the current Annotator object, if one exists.
var g = Util.getGlobal();
var _Annotator = g.Annotator;

// If wicked-good-xpath is available, install it. This will not overwrite any
// native XPath functionality.
if (typeof g.wgxpath !== "undefined" &&
    g.wgxpath !== null &&
    typeof g.wgxpath.install === "function") {
    g.wgxpath.install();
}

// Annotator represents a sane default configuration of Annotator, with a
// default set of plugins and a user interface.
var Annotator = Core.Annotator.extend({

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
        Core.Annotator.call(this);

        Annotator._instances.push(this);

        // Return early if the annotator is not supported.
        if (!Annotator.supported()) {
            return this;
        }

        this.setAuthorizer(Authorizer.Default({}));
        this.setIdentifier(Identifier.Default(null));
        this.setNotifier(Notifier.Banner);
        this.setStorage(Storage.NullStorage);
        this.addPlugin(defaultUI(element, options));
    },

    // Public: Destroy the current Annotator instance, unbinding all events and
    // disposing of all relevant elements.
    //
    // Returns nothing.
    destroy: function () {
        Core.Annotator.prototype.destroy.call(this);

        var idx = Annotator._instances.indexOf(this);
        if (idx !== -1) {
            Annotator._instances.splice(idx, 1);
        }
    }
});


// Create namespace object for core-provided plugins
Annotator.Plugin = {};

// Export other modules for use in plugins.
Annotator.Authorizer = Authorizer;
Annotator.Core = Core;
Annotator.Identifier = Identifier;
Annotator.Notifier = Notifier;
Annotator.Storage = Storage;
Annotator.UI = require('./ui');
Annotator.Util = Util;

// Expose a global instance registry
Annotator._instances = [];

// Bind gettext helper so plugins can use localisation.
var _t = Util.gettext;
Annotator._t = _t;

// Returns true if the Annotator can be used in the current environment.
Annotator.supported = function (details, scope) {
    if (typeof scope === 'undefined' || scope === null) {
        scope = Util.getGlobal();
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
};

// Restores the Annotator property on the global object to it's
// previous value and returns the Annotator.
Annotator.noConflict = function () {
    g.Annotator = _Annotator;
    return Annotator;
};


// Export Annotator object.
module.exports = Annotator;
