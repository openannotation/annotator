/*package annotator.core */

"use strict";

var extend = require('backbone-extend-standalone');

var storage = require('./storage');
var Promise = require('./util').Promise;

/**
 * class:: Annotator()
 *
 * Annotator is the coordination point for all annotation functionality. On
 * its own it provides only the necessary code for coordinating the lifecycle of
 * annotation objects. It requires at least a storage plugin to be useful.
 */
function Annotator() {
    this.plugins = [];
    this.registry = {};

    // This is here so it can be overridden when testing
    this._storageAdapterType = storage.StorageAdapter;
}

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
 * function:: Annotator.prototype.destroy()
 *
 * Destroy the current instance
 *
 * Destroys all remnants of the current AnnotatorBase instance by calling the
 * destroy method, if it exists, on each plugin object.
 *
 * :returns Promise: Resolved when all plugin destroy hooks are completed.
 */
Annotator.prototype.destroy = function () {
    return this.runHook('onDestroy');
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
 * function:: Annotator.prototype.setAuthorizer(authorizerFunc)
 *
 * Set the authorizer implementation
 *
 * :param Function authorizerFunc:
 *   A function returning an authorizer component. An authorizer component must
 *   implement the Authorizer interface.
 *
 * :returns: The Annotator instance, to allow chained method calls.
 */
Annotator.prototype.setAuthorizer = function (authorizerFunc) {
    var authorizer = authorizerFunc(this.registry);
    this.registry.authorizer = authorizer;
    return this;
};

/**
 * function:: Annotator.prototype.setIdentifier(identifierFunc)
 *
 * Set the identifier implementation
 *
 * :param Function identifierFunc:
 *   A function returning an identifier component. An identifier component must
 *   implement the Identifier interface.
 *
 * :returns: The Annotator instance, to allow chained method calls.
 */
Annotator.prototype.setIdentifier = function (identifierFunc) {
    var identifier = identifierFunc(this.registry);
    this.registry.identifier = identifier;
    return this;
};

/**
 * function:: Annotator.prototype.setNotifier(notifierFunc)
 *
 * Set the notifier implementation
 *
 * :param Function notifierFunc:
 *   A function returning a notifier component. A notifier component must
 *   implement the Notifier interface.
 *
 * :returns: The Annotator instance, to allow chained method calls.
 */
Annotator.prototype.setNotifier = function (notifierFunc) {
    var notifier = notifierFunc(this.registry);
    this.registry.notifier = notifier;
    return this;
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
 * function:: Annotator.extend(object)
 *
 * Create a new object which inherits from the Annotator class.
 */
Annotator.extend = extend;


exports.Annotator = Annotator;
