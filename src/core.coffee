Storage = require('./storage')
Promise = require('./util').Promise

# AnnotatorCore is the coordination point for all annotation functionality. On
# its own it provides only the necessary code for coordinating the lifecycle of
# annotation objects. It requires at least a storage plugin to be useful.
class AnnotatorCore

  constructor: ->
    @plugins = []
    @registry = {}

    # This is here so it can be overridden when testing
    @_storageAdapterType = Storage.StorageAdapter

  # Public: Register a plugin
  #
  # plugin - A plugin to instantiate. A plugin is a function that accepts a
  #          Registry object for the current Annotator and returns a plugin
  #          object. A plugin object may define function properties wi
  #
  # Examples
  #
  #   var creationNotifier = function (registry) {
  #       return {
  #           onAnnotationCreated: function (ann) {
  #               console.log("annotationCreated", ann);
  #           }
  #       }
  #   }
  #
  #   annotator
  #     .addPlugin(Annotator.Plugin.Tags)
  #     .addPlugin(creationNotifier)
  #
  # Returns the instance to allow chaining.
  addPlugin: (plugin) ->
    @plugins.push(plugin(@registry))
    this

  # Public: Destroy the current instance
  #
  # Destroys all remnants of the current AnnotatorBase instance by calling the
  # destroy method, if it exists, on each plugin object.
  #
  # Returns nothing.
  destroy: ->
    this.runHook('onDestroy')

  # Public: Run the named hook with the provided arguments
  #
  # Returns a Promise.all(...) over the hook handler return values.
  runHook: (name, args) => # This is bound so it can be passed around on its own
    results = []
    for plugin in @plugins
      if typeof plugin[name] == 'function'
        results.push(plugin[name].apply(plugin, args))
    return Promise.all(results)

  # Public: Set the notification implementation
  #
  # notificationFunc - A function returning a notification component. A
  #                    notification component must implement the Notification
  #                    interface.
  #
  # Returns the instance to allow chaining.
  setNotification: (notificationFunc) ->
    notification = notificationFunc()
    @registry.notification = notification
    this

  # Public: Set the storage implementation
  #
  # storageFunc - A function returning a storage component. A storage component
  #               must implement the Storage interface.
  #
  # Returns the instance to allow chaining.
  setStorage: (storageFunc) ->
    # setStorage takes a function returning a storage object, and not a storage
    # object, for the sake of consistency with addPlugin, e.g.
    #
    # ann
    #   .addPlugin(Annotator.Plugins.Tags)
    #   .setStorage(Annotator.Plugins.NullStore)
    #
    # It's certainly not needed (as storage functions don't accept any
    # arguments) but it does seem cleaner this way.
    storage = storageFunc()
    adapter = new @_storageAdapterType(storage, this.runHook)
    @registry.annotations = adapter
    this


# Exports
exports.AnnotatorCore = AnnotatorCore
