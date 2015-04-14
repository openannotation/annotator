/*package annotator */

"use strict";

var extend = require('backbone-extend-standalone');
var Promise = require('./util').Promise;

var authorizer = require('./authorizer');
var identifier = require('./identifier');
var notifier = require('./notifier');
var registry = require('./registry');
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

/**
 * class:: App([options])
 *
 * App is the coordination point for all annotation functionality. App instances
 * manage the configuration of a particular annotation application, and are the
 * starting point for most deployments of Annotator.
 */
function App(options) {
    // Hold a reference to the instance.
    instances.push(this);

    this.options = options;
    this._finalized = false;

    // Return early if the annotator is not supported.
    if (!supported()) {
        return this;
    }

    this.plugins = [];
    this.registry = new registry.Registry();
    this.registry.registerUtility(authorizer.Default({}), 'authorizer');
    this.registry.registerUtility(identifier.Default(null), 'identifier');
    this.registry.registerUtility(notifier.Banner, 'notifier');
    this.registry.registerUtility(storage.NullStorage, 'storage');
}

/**
 * function:: App.prototype.finalize()
 *
 * Tells the app that configuration is complete, and binds the various
 * components passed to the registry to their canonical names so they can be
 * used by the rest of the application.
 *
 * You won't usually need to call this yourself.
 */
App.prototype.finalize = function () {
    if (this._finalized) {
        return;
    }

    var self = this;

    this.registry.authorizer = this.registry.getUtility('authorizer')();
    this.registry.identifier = this.registry.getUtility('identifier')();
    this.registry.notifier = this.registry.getUtility('notifier')();

    this.annotations = this.registry.annotations = new storage.StorageAdapter(
        this.registry.getUtility('storage')(),
        function () {
            return self.runHook.apply(self, arguments);
        }
    );

    this._finalized = true;
};

/**
 * function:: App.prototype.start(element)
 *
 * Start listening for selection events on `element`.
 */
App.prototype.start = function (element) {
    this.finalize();
    this.addPlugin(defaultUI(element, this.options));
};


/**
 * function:: App.prototype.addPlugin(plugin)
 *
 * Register a plugin
 *
 * **Examples**:
 *
 * ::
 *
 *     function creationNotifier(registry) {
 *         return {
 *             onAnnotationCreated: function (ann) {
 *                 console.log("annotationCreated", ann);
 *             }
 *         }
 *     }
 *
 *     annotator
 *       .addPlugin(annotator.plugin.Tags)
 *       .addPlugin(creationNotifier)
 *
 *
 * :param plugin:
 *   A plugin to instantiate. A plugin is a function that accepts a Registry
 *   object for the current App and returns a plugin object. A plugin
 *   object may define function properties wi
 * :returns: The Annotator instance, to allow chained method calls.
 */
App.prototype.addPlugin = function (plugin) {
    this.plugins.push(plugin(this.registry));
    return this;
};


/**
 * function:: App.prototype.runHook(name[, args])
 *
 * Run the named hook with the provided arguments
 *
 * :returns Promise: Resolved when all over the hook handlers are complete.
 */
App.prototype.runHook = function (name, args) {
    var results = [];
    for (var i = 0, len = this.plugins.length; i < len; i++) {
        var plugin = this.plugins[i];
        if (typeof plugin[name] === 'function') {
            results.push(plugin[name].apply(plugin, args));
        }
    }
    return Promise.all(results);
};


/**
 * function:: App.prototype.destroy()
 *
 * Destroy the App. Unbinds all event handlers and runs the 'onDestroy' hooks
 * for any plugins.
 *
 * :returns Promise: Resolved when destroyed.
 */
App.prototype.destroy = function () {
    var self = this;
    return this.runHook('onDestroy')
    .then(function () {
        var idx = instances.indexOf(self);
        if (idx !== -1) {
            instances.splice(idx, 1);
        }
    });
};


/**
 * function:: App.extend(object)
 *
 * Create a new object which inherits from the App class.
 */
App.extend = extend;


/**
 * function:: supported([details=false, scope=window])
 *
 * Examines `scope` (by default the global window object) to determine if
 * Annotator can be used in this environment.
 *
 * :returns Boolean:
 *   Whether Annotator can be used in `scope`, if `details` is
 *   false.
 * :returns Object:
 *   If `details` is true. Properties:
 *
 *   - `supported`: Boolean, whether Annotator can be used in `scope`.
 *   - `details`: Array of String reasons why Annotator cannot be used.
 */
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


exports.App = App;
exports.supported = supported;
