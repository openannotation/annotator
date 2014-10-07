"use strict";

var extend = require('backbone-extend-standalone');

var Storage = require('./storage'),
    Promise = require('./util').Promise;

// AnnotatorCore is the coordination point for all annotation functionality. On
// its own it provides only the necessary code for coordinating the lifecycle of
// annotation objects. It requires at least a storage plugin to be useful.
function AnnotatorCore() {
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
AnnotatorCore.prototype.addPlugin = function (plugin) {
    this.plugins.push(plugin(this.registry));
    return this;
};

// Public: Destroy the current instance
//
// Destroys all remnants of the current AnnotatorBase instance by calling the
// destroy method, if it exists, on each plugin object.
//
// Returns a Promise resolved when all plugin destroy hooks are completed.
AnnotatorCore.prototype.destroy = function () {
    return this.runHook('onDestroy');
};

// Public: Run the named hook with the provided arguments
//
// Returns a Promise.all(...) over the hook handler return values.
AnnotatorCore.prototype.runHook = function (name, args) {
    var results = [];
    for (var i = 0, len = this.plugins.length; i < len; i++) {
        var plugin = this.plugins[i];
        if (typeof plugin[name] == 'function') {
            results.push(plugin[name].apply(plugin, args));
        }
    }
    return Promise.all(results);
};

// Public: Set the notification implementation
//
// notificationFunc - A function returning a notification component. A
//                    notification component must implement the Notification
//                    interface.
//
// Returns the instance to allow chaining.
AnnotatorCore.prototype.setNotification = function (notificationFunc) {
    var notification = notificationFunc();
    this.registry.notification = notification;
    return this;
};

// Public: Set the storage implementation
//
// storageFunc - A function returning a storage component. A storage component
//               must implement the Storage interface.
//
// Returns the instance to allow chaining.
AnnotatorCore.prototype.setStorage = function (storageFunc) {
    // setStorage takes a function returning a storage object, and not a storage
    // object, for the sake of consistency with addPlugin, e.g.
    //
    // ann
    //   .addPlugin(Annotator.Plugins.Tags)
    //   .setStorage(Annotator.Plugins.NullStore)
    //
    // It's certainly not needed (as storage functions don't accept any
    // arguments) but it does seem cleaner this way.
    var self = this,
        storage = storageFunc(),
        adapter = new this._storageAdapterType(storage, function () {
            return self.runHook.apply(self, arguments);
        });
    this.registry.annotations = adapter;
    return this;
};

// Public: Create an object that extends (subclasses) AnnotatorCore.
AnnotatorCore.extend = extend;


// Exports
exports.AnnotatorCore = AnnotatorCore;
