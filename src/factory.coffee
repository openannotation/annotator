# Factory is a factory for Annotator-based applications. It allows you to
# configure and coordinate a set of components from Annotator and third-party
# libraries in a clear, configurable way.
class Factory
  # Public: create an Annotator factory object.
  #
  # core - Constructor for Annotator's core object. This is likely to be either
  #        the Annotator class or an extended version thereof.
  constructor: (core) ->
    @ctors = {}
    @ctors.core = core

    @pluginCtors = []

  # Public: given the current configuration of the factory, get an instance of
  # core constructor (usually an instance of Annotator). This instance will be
  # configured with store and plugins as specified to the factory, but will not
  # be bound to any element.
  getInstance: ->
    obj = new @ctors.core
    plugins = []

    # If we have a `store` ctor, use it
    if @ctors.store?
      store = new @ctors.store

    for pCtor in @pluginCtors
      plugins.push(new pCtor)

    # Configure core
    if obj.configure?
      obj.configure({
        store: if store? then store else null
        plugins: plugins
      })

    # Configure components
    if store?.configure?
      store.configure(core: obj)

    for p in plugins
      if p.configure?
        p.configure(core: obj)

    #...

    return obj

  # Public: set the constructor to be used for the store. This constructor must
  # return an object which conforms to the store API.
  #
  # store - The constructor for the store object.
  setStore: (store) ->
    @ctors.store = store

  # Public: append the selected plugin to the list of plugins to be instantiate
  # for each create instance.
  #
  # plugin - The constructor for the plugin object.
  addPlugin: (plugin) ->
    @pluginCtors.push(plugin)


module.exports = Factory
