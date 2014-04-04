Delegator = require("./delegator")
Util = require("./util")


# Public: A base plugin class
class Plugin extends Delegator
  constructor: ->
    if @constructor.name? # Function#name is ES6 and not widely supported yet
      name = @constructor.name
    else
      name = "This"
    Util.deprecationWarning("#{name} plugin inherits from Annotator.Plugin:
                             doing so is deprecated. If you need Delegator
                             functionality, please extend Annotator.Delegator
                             directly.")
    super

  pluginInit: ->

  destroy: ->
    this.removeEvents()


# Map of plugin names to constructors
Plugin._ctors = {}


# Register a plugin.
#
# name - The unique name of the plugin.
# ctor - The plugin constructor function.
Plugin.register = (name, ctor) ->
  Plugin._ctors[name] = ctor

  # Register a property so that this constructor can be accessed in the old
  # and deprecate way, directly on the pool instance, but throw a deprecation
  # warning when accessed.
  #
  # @slatedForDeprecation 2.1.0
  Object.defineProperty(Plugin, name, {
    configurable: true
    get: ->
      Util.deprecationWarning("Direct access to plugin constructors through
                               the Annotator.Plugin namespace is deprecated.
                               Please use Annotator.Plugin.fetch('#{name}')!")
      Plugin._ctors[name]
  })


# Fetch a plugin constructor from the pool by name.
#
# name - The name of the plugin.
Plugin.fetch = (name) ->
  Plugin._ctors[name]


# Check for old-style plugin bindings and issue deprecation warnings
#
# @slatedForDeprecation 2.1.0
Plugin._rebindOldPlugins = ->
  ignore = ['__super__', '_ctors', '_rebindOldPlugins', 'register', 'fetch']
  for own k, v of Plugin when k not in ignore
    Util.deprecationWarning("Direct assignment of plugin constructors to the
                             Annotator.Plugin namespace is deprecated. Please
                             use Annotator.Plugin.register('#{k}', #{k})
                             instead! Automatically re-registering plugin...")
    delete Plugin._ctors[k]
    Plugin.register(k, v)


module.exports = Plugin
