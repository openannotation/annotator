/*package annotator */

"use strict";

var extend = require('backbone-extend-standalone');
var Promise = require('es6-promise').Promise;

var authz = require('./authz');
var identity = require('./identity');
var notification = require('./notification');
var registry = require('./registry');
var storage = require('./storage');

/**
 * class:: App()
 *
 * App is the coordination point for all annotation functionality. App instances
 * manage the configuration of a particular annotation application, and are the
 * starting point for most deployments of Annotator.
 */
function App() {
    this.modules = [];
    this.registry = new registry.Registry();

    this._started = false;

    // Register a bunch of default utilities
    this.registry.registerUtility(notification.defaultNotifier,
                                  'notifier');

    // And set up default components.
    this.include(authz.acl);
    this.include(identity.simple);
    this.include(storage.noop);
}


/**
 * function:: App.prototype.include(module[, options])
 *
 * Include an extension module. If an `options` object is supplied, it will be
 * passed to the module at initialisation.
 *
 * If the returned module instance has a `configure` function, this will be
 * called with the application registry as a parameter.
 *
 * :param Object module:
 * :param Object options:
 * :returns: Itself.
 * :rtype: App
 */
App.prototype.include = function (module, options) {
    var mod = module(options);
    if (typeof mod.configure === 'function') {
        mod.configure(this.registry);
    }
    this.modules.push(mod);
    return this;
};


/**
 * function:: App.prototype.start()
 *
 * Tell the app that configuration is complete. This binds the various
 * components passed to the registry to their canonical names so they can be
 * used by the rest of the application.
 *
 * Runs the 'start' module hook.
 *
 * :returns: A promise, resolved when all module 'start' hooks have completed.
 * :rtype: Promise
 */
App.prototype.start = function () {
    if (this._started) {
        return;
    }
    this._started = true;

    var self = this;
    var reg = this.registry;

    this.authz = reg.getUtility('authorizationPolicy');
    this.ident = reg.getUtility('identityPolicy');
    this.notify = reg.getUtility('notifier');

    this.annotations = new storage.StorageAdapter(
        reg.getUtility('storage'),
        function () {
            return self.runHook.apply(self, arguments);
        }
    );

    return this.runHook('start', [this]);
};


/**
 * function:: App.prototype.destroy()
 *
 * Destroy the App. Unbinds all event handlers and runs the 'destroy' module
 * hook.
 *
 * :returns: A promise, resolved when destroyed.
 * :rtype: Promise
 */
App.prototype.destroy = function () {
    return this.runHook('destroy');
};


/**
 * function:: App.prototype.runHook(name[, args])
 *
 * Run the named module hook and return a promise of the results of all the hook
 * functions. You won't usually need to run this yourself unless you are
 * extending the base functionality of App.
 *
 * Optionally accepts an array of argument (`args`) to pass to each hook
 * function.
 *
 * :returns: A promise, resolved when all hooks are complete.
 * :rtype: Promise
 */
App.prototype.runHook = function (name, args) {
    var results = [];
    for (var i = 0, len = this.modules.length; i < len; i++) {
        var mod = this.modules[i];
        if (typeof mod[name] === 'function') {
            results.push(mod[name].apply(mod, args));
        }
    }
    return Promise.all(results);
};


/**
 * function:: App.extend(object)
 *
 * Create a new object that inherits from the App class.
 *
 * For example, here we create a ``CustomApp`` that will include the
 * hypothetical ``mymodules.foo.bar`` module depending on the options object
 * passed into the constructor::
 *
 *     var CustomApp = annotator.App.extend({
 *         constructor: function (options) {
 *             App.apply(this);
 *             if (options.foo === 'bar') {
 *                 this.include(mymodules.foo.bar);
 *             }
 *         }
 *     });
 *
 *     var app = new CustomApp({foo: 'bar'});
 *
 * :returns: The subclass constructor.
 * :rtype: Function
 */
App.extend = extend;


exports.App = App;
