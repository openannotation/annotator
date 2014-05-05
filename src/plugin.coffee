Delegator = require("./delegator")
Util = require("./util")
$ = Util.$


# Public: A base plugin class
class Plugin extends Delegator
  constructor: ->
    super
    if @constructor.name? # Function#name is ES6 and not widely supported yet
      name = @constructor.name
    else
      name = "This"
    Util.deprecationWarning("#{name} plugin inherits from Annotator.Plugin:
                             doing so is deprecated. If you need Delegator
                             functionality, please extend Annotator.Delegator
                             directly.")

  pluginInit: ->
    if @_oldStyleEvents? and Object.keys(@_oldStyleEvents)
      Util.deprecationWarning("Binding custom events using the events hash
                               is deprecated. If you need to listen to custom
                               events bind explicitly using something like
                               `this.listenTo(this.annotator, ...)`.")
      for event, functionName of @_oldStyleEvents
        this.listenTo(@annotator, event, this[functionName])

  _addEvent: (selector, event, functionName) ->
    if selector == '' and _isCustomEvent(event)
      @_oldStyleEvents ?= {}
      @_oldStyleEvents[event] = functionName
    else
      super
    this

  _removeEvent: (selector, event, functionName) ->
    if selector == '' and _isCustomEvent(event)
      this.stopListening(@annotator, event, this[functionName])
    else
      super
    this


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


# Native jQuery events that should recieve an event object.
natives = do ->
  specials = (key for own key, val of $.event.special)
  """
  blur focus focusin focusout load resize scroll unload click dblclick
  mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave
  change select submit keydown keypress keyup error
  """.split(/[^a-z]+/).concat(specials)


# Checks to see if the provided event is a DOM event supported by jQuery or
# a custom user event.
#
# event - String event name.
#
# Examples
#
#   _isCustomEvent('click')              # => false
#   _isCustomEvent('mousedown')          # => false
#   _isCustomEvent('annotation:created') # => true
#
# Returns true if event is a custom user event.
_isCustomEvent = (event) ->
  [event] = event.split('.')
  $.inArray(event, natives) == -1


module.exports = Plugin
