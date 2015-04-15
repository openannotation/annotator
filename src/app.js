/*package annotator */

"use strict";

var extend = require('backbone-extend-standalone');
var Promise = require('./util').Promise;

var authz = require('./authz');
var identity = require('./identity');
var notification = require('./notification');
var registry = require('./registry');
var storage = require('./storage');
var util = require('./util');

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

/**
 * class:: App([options])
 *
 * App is the coordination point for all annotation functionality. App instances
 * manage the configuration of a particular annotation application, and are the
 * starting point for most deployments of Annotator.
 */
function App(options) {
    this.options = options;
    this._started = false;

    // Return early if the annotator is not supported.
    if (!supported()) {
        return this;
    }

    this.plugins = [];
    this.registry = new registry.Registry();

    // Register a bunch of default utilities
    this.registry.registerUtility(authz.defaultAuthorizationPolicy,
                                  'authorizationPolicy');
    this.registry.registerUtility(identity.defaultIdentityPolicy,
                                  'identityPolicy');
    this.registry.registerUtility(notification.defaultNotifier,
                                  'notifier');

    // And set up a default storage component.
    this.include(storage.nullStorage);
}


/**
 * function:: App.prototype.include(module[, options])
 *
 * Include a plugin module. If an `options` object is supplied, it will be
 * passed to the plugin module at initialisation.
 *
 * If the returned plugin has a `configure` function, this will be called with
 * the application registry as its first parameter.
 *
 * :param Object module:
 * :param Object options:
 * :returns: The Annotator instance, to allow chained method calls.
 */
App.prototype.include = function (module, options) {
    var plugin = module(options);
    if (typeof plugin.configure === 'function') {
        plugin.configure(this.registry);
    }
    this.plugins.push(plugin);
    return this;
};


/**
 * function:: App.prototype.start()
 *
 * Tell the app that configuration is complete. This binds the various
 * components passed to the registry to their canonical names so they can be
 * used by the rest of the application.
 *
 * Runs the 'start' plugin hook.
 *
 * :returns Promise: Resolved when all plugin 'start' hooks have completed.
 */
App.prototype.start = function () {
    if (this._started) {
        return;
    }
    this._started = true;

    var self = this;
    var reg = this.registry;

    this.authz = reg.authz = reg.getUtility('authorizationPolicy');
    this.ident = reg.ident = reg.getUtility('identityPolicy');
    this.notify = reg.notify = reg.getUtility('notifier');

    this.annotations = reg.annotations = new storage.StorageAdapter(
        reg.getUtility('storage'),
        function () {
            return self.runHook.apply(self, arguments);
        }
    );

    return this.runHook('start');
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
 * Destroy the App. Unbinds all event handlers and runs the 'destroy' plugin
 * hook.
 *
 * :returns Promise: Resolved when destroyed.
 */
App.prototype.destroy = function () {
    return this.runHook('destroy');
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
