"use strict";

var extend = require('backbone-extend-standalone');

var Storage = require('./storage'),
    Promise = require('./util').Promise;

// Annotator is the coordination point for all annotation functionality. On
// its own it provides only the necessary code for coordinating the lifecycle of
// annotation objects. It requires at least a storage plugin to be useful.
function Annotator() {
    this.plugins = [];
    this.registry = {};

    // This is here so it can be overridden when testing
    this._storageAdapterType = Storage.StorageAdapter;
}

// Public: Register a plugin
//
// plugin - A plugin to instantiate. A plugin is a function that accepts a
//          Registry object for the current Annotator and returns a plugin
//          object. A plugin object may define function properties wi
//
// Examples
//
//   function creationNotifier(registry) {
//       return {
//           onAnnotationCreated: function (ann) {
//               console.log("annotationCreated", ann);
//           }
//       }
//   }
//
//   annotator
//     .addPlugin(Annotator.Plugin.Tags)
//     .addPlugin(creationNotifier)
//
// Returns the instance to allow chaining.
Annotator.prototype.addPlugin = function (plugin) {
    this.plugins.push(plugin(this.registry));
    return this;
};

// Public: Destroy the current instance
//
// Destroys all remnants of the current AnnotatorBase instance by calling the
// destroy method, if it exists, on each plugin object.
//
// Returns a Promise resolved when all plugin destroy hooks are completed.
Annotator.prototype.destroy = function () {
    return this.runHook('onDestroy');
};

// Public: Run the named hook with the provided arguments
//
// Returns a Promise.all(...) over the hook handler return values.
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

// Public: Set the authorizer implementation
//
// authorizerFunc - A function returning an authorizer component. An authorizer
//                  component must implement the Authorizer interface.
//
// Returns the instance to allow chaining.
Annotator.prototype.setAuthorizer = function (authorizerFunc) {
    var authorizer = authorizerFunc(this.registry);
    this.registry.authorizer = authorizer;
    return this;
};

// Public: Set the identifier implementation
//
// identifierFunc - A function returning an identifier component. An identifier
//                  component must implement the Identifier interface.
//
// Returns the instance to allow chaining.
Annotator.prototype.setIdentifier = function (identifierFunc) {
    var identifier = identifierFunc(this.registry);
    this.registry.identifier = identifier;
    return this;
};

// Public: Set the notifier implementation
//
// notifierFunc - A function returning a notifier component. A notifier
//                component must implement the Notifier interface.
//
// Returns the instance to allow chaining.
Annotator.prototype.setNotifier = function (notifierFunc) {
    var notifier = notifierFunc(this.registry);
    this.registry.notifier = notifier;
    return this;
};

// Public: Set the storage implementation
//
// storageFunc - A function returning a storage component. A storage component
//               must implement the Storage interface.
//
// Returns the instance to allow chaining.
Annotator.prototype.setStorage = function (storageFunc) {
    var self = this,
        storage = storageFunc(this.registry),
        adapter = new this._storageAdapterType(storage, function () {
            return self.runHook.apply(self, arguments);
        });
    this.registry.annotations = adapter;
    return this;
};

// Public: Create an object that extends (subclasses) Annotator.
Annotator.extend = extend;


// Exports
exports.Annotator = Annotator;
