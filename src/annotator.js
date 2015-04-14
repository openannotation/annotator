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
 * class:: Annotator([options])
 *
 * Annotator is the coordination point for all annotation functionality.
 * Annotator instances manage the configuration of a particular annotation
 * application, and are the starting point for most deployments of Annotator.
 */
function Annotator(options) {
    // Hold a reference to the instance.
    instances.push(this);

    this.options = options;

    // Return early if the annotator is not supported.
    if (!supported()) {
        return this;
    }

    // This is here so it can be overridden when testing
    this._storageAdapterType = storage.StorageAdapter;

    this.plugins = [];
    this.registry = new registry.Registry();
    this.registry.registerUtility(authorizer.Default({}), 'authorizer');
    this.registry.registerUtility(identifier.Default(null), 'identifier');
    this.registry.registerUtility(notifier.Banner, 'notifier');
    this.setStorage(storage.NullStorage);

    // For now, we set these properties explicitly on the registry. This is
    // not how (or where) this should be done once we have a separate
    // configuration stage.
    this.registry.authorizer = this.registry.getUtility('authorizer')();
    this.registry.identifier = this.registry.getUtility('identifier')();
    this.registry.notifier = this.registry.getUtility('notifier')();
}


/**
 * function:: Annotator.prototype.start(element)
 *
 * Start listening for selection events on `element`.
 */
Annotator.prototype.start = function (element) {
    this.addPlugin(defaultUI(element, this.options));
};


/**
 * function:: Annotator.prototype.addPlugin(plugin)
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
 *   object for the current Annotator and returns a plugin object. A plugin
 *   object may define function properties wi
 * :returns: The Annotator instance, to allow chained method calls.
 */
Annotator.prototype.addPlugin = function (plugin) {
    this.plugins.push(plugin(this.registry));
    return this;
};


/**
 * function:: Annotator.prototype.runHook(name[, args])
 *
 * Run the named hook with the provided arguments
 *
 * :returns Promise: Resolved when all over the hook handlers are complete.
 */
Annotator.prototype.runHook = function (name, args) {
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
 * function:: Annotator.prototype.setStorage(storageFunc)
 *
 * Set the storage implementation
 *
 * :param Function storageFunc:
 *   A function returning a storage component. A storage component must
 *   implement the Storage interface.
 *
 * :returns: The Annotator instance, to allow chained method calls.
 */
Annotator.prototype.setStorage = function (storageFunc) {
    var self = this,
        storage = storageFunc(this.registry),
        adapter = new this._storageAdapterType(storage, function () {
            return self.runHook.apply(self, arguments);
        });
    this.registry.annotations = adapter;
    return this;
};


/**
 * function:: Annotator.prototype.destroy()
 *
 * Destroy the current Annotator instance. Unbinds all event handlers and
 * runs the 'onDestroy' hooks for any plugins.
 *
 * :returns Promise: Resolved when destroyed.
 */
Annotator.prototype.destroy = function () {
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
 * function:: Annotator.extend(object)
 *
 * Create a new object which inherits from the Annotator class.
 */
Annotator.extend = extend;


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


exports.Annotator = Annotator;
exports.supported = supported;
