Util = require './util'


# Public: Delegator is the base class that all of Annotators objects inherit
# from. It provides basic functionality such as instance options, event
# delegation and pub/sub methods.
class Delegator
  # Public: Events object. This contains a key/pair hash of events/methods that
  # should be bound. See Delegator#addEvents() for usage.
  events: {}

  # Public: Options object. Extended on initialisation.
  options: {}

  # A jQuery object wrapping the DOM Element provided on initialisation.
  element: null

  # Public: Constructor function that sets up the instance. Binds the @events
  # hash and extends the @options object.
  #
  # element - The DOM element that this intance represents.
  # options - An Object literal of options.
  #
  # Examples
  #
  #   element  = document.getElementById('my-element')
  #   instance = new Delegator(element, {
  #     option: 'my-option'
  #   })
  #
  # Returns a new instance of Delegator.
  constructor: (element, options) ->
    @options = $.extend(true, {}, @options, options)
    @element = $(element)

    # Delegator creates closures for each event it binds. This is a private
    # registry of created closures, used to enable event unbinding.
    @_closures = {}

    this.addEvents()

  # Public: binds the function names in the @events Object to their events.
  #
  # The @events Object should be a set of key/value pairs where the key is the
  # event name with optional CSS selector. The value should be a String method
  # name on the current class.
  #
  # This is called by the default Delegator constructor and so shouldn't usually
  # need to be called by the user.
  #
  # Examples
  #
  #   # This will bind the clickedElement() method to the click event on @element.
  #   @options = {"click": "clickedElement"}
  #
  #   # This will delegate the submitForm() method to the submit event on the
  #   # form within the @element.
  #   @options = {"form submit": "submitForm"}
  #
  #   # This will bind the updateAnnotationStore() method to the custom
  #   # annotation:save event. NOTE: Because this is a custom event the
  #   # Delegator#subscribe() method will be used and updateAnnotationStore()
  #   # will not recieve an event parameter like the previous two examples.
  #   @options = {"annotation:save": "updateAnnotationStore"}
  #
  # Returns nothing.
  addEvents: ->
    for event in Delegator._parseEvents(@events)
      this._addEvent(event.selector, event.event, event.functionName)

  # Public: unbinds functions previously bound to events by addEvents().
  #
  # The @events Object should be a set of key/value pairs where the key is the
  # event name with optional CSS selector. The value should be a String method
  # name on the current class.
  #
  # Returns nothing.
  removeEvents: ->
    for event in Delegator._parseEvents(@events)
      this._removeEvent(event.selector, event.event, event.functionName)

  # Binds an event to a callback function represented by a String. A selector
  # can be provided in order to watch for events on a child element.
  #
  # The event can be any standard event supported by jQuery or a custom String.
  # If a custom string is used the callback function will not receive an event
  # object as its first parameter.
  #
  # selector     - Selector String matching child elements. (default: '')
  # event        - The event to listen for.
  # functionName - A String function name to bind to the event.
  #
  # Examples
  #
  #   # Listens for all click events on instance.element.
  #   instance._addEvent('', 'click', 'onClick')
  #
  #   # Delegates the instance.onInputFocus() method to focus events on all
  #   # form inputs within instance.element.
  #   instance._addEvent('form :input', 'focus', 'onInputFocus')
  #
  # Returns itself.
  _addEvent: (selector, event, functionName) ->
    closure = => this[functionName].apply(this, arguments)

    if selector == '' and Delegator._isCustomEvent(event)
      this.subscribe(event, closure)
    else
      @element.delegate(selector, event, closure)

    @_closures["#{selector}/#{event}/#{functionName}"] = closure

    this

  # Unbinds a function previously bound to an event by the _addEvent method.
  #
  # Takes the same arguments as _addEvent(), and an event will only be
  # successfully unbound if the arguments to removeEvent() are exactly the same
  # as the original arguments to _addEvent(). This would usually be called by
  # _removeEvents().
  #
  # selector     - Selector String matching child elements. (default: '')
  # event        - The event to listen for.
  # functionName - A String function name to bind to the event.
  #
  # Returns itself.
  _removeEvent: (selector, event, functionName) ->
    closure = @_closures["#{selector}/#{event}/#{functionName}"]

    if selector == '' and Delegator._isCustomEvent(event)
      this.unsubscribe(event, closure)
    else
      @element.undelegate(selector, event, closure)

    delete @_closures["#{selector}/#{event}/#{functionName}"]

    this

  # Public: Fires an event and calls all subscribed callbacks with parameters
  # provided. This is essentially an alias to Backbone.Events .trigger()
  # except that the arguments are passed in an Array as the second parameter
  # rather than using a variable number of arguments.
  publish: (name, args=[]) ->
    this.trigger.apply(this, [name, args...])

  # Public: An alias for .on() from Backbone.Events
  subscribe: (event, callback, context=this) ->
    this.on(event, callback, context)

  # Public: An alias for .off() from Backbone.Events
  unsubscribe: (event, callback, context=this) ->
    this.off(event, callback, context)


# Parse the @events object of a Delegator into an array of objects containing
# string-valued "selector", "event", and "func" keys.
Delegator._parseEvents = (eventsObj) ->
    events = []
    for sel, functionName of eventsObj
      [selector..., event] = sel.split ' '
      events.push({
        selector: selector.join(' '),
        event: event,
        functionName: functionName
      })
    return events


# Native jQuery events that should recieve an event object. Plugins can
# add their own methods to this if required.
Delegator.natives = do ->
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
#   Delegator._isCustomEvent('click')              # => false
#   Delegator._isCustomEvent('mousedown')          # => false
#   Delegator._isCustomEvent('annotation:created') # => true
#
# Returns true if event is a custom user event.
Delegator._isCustomEvent = (event) ->
  [event] = event.split('.')
  $.inArray(event, Delegator.natives) == -1


# Mix in backbone events
BackboneEvents = require 'backbone-events-standalone'
BackboneEvents.mixin(Delegator::)

# Export Delegator object
module.exports = Delegator
