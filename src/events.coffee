# TODO: replace this with Backbone.Events or similar
class Evented
  # Public: Fires an event and calls all subscribed callbacks with any parameters
  # provided. This is essentially an alias of $(this).triggerHandler() but
  # should be used to fire custom events.
  #
  # NOTE: Events fired using .publish() will not bubble up the DOM.
  #
  # event  - A String event name.
  # params - An Array of parameters to provide to callbacks.
  #
  # Examples
  #
  #   instance.subscribe('annotation:save', (msg) -> console.log(msg))
  #   instance.publish('annotation:save', ['Hello World'])
  #   # => Outputs "Hello World"
  #
  # Returns itself.
  publish: () ->
    $(this).triggerHandler.apply($(this), arguments)
    this

  # Public: Listens for custom event which when published will call the provided
  # callback. This is essentially a wrapper around $(this).bind() but removes
  # the event parameter that jQuery event callbacks always recieve. These
  # parameters are unnessecary for custom events.
  #
  # event    - A String event name.
  # callback - A callback function called when the event is published.
  #
  # Examples
  #
  #   instance.subscribe('annotation:save', (msg) -> console.log(msg))
  #   instance.publish('annotation:save', ['Hello World'])
  #   # => Outputs "Hello World"
  #
  # Returns itself.
  subscribe: (event, callback, context=this) ->
    closure = -> callback.apply(context, [].slice.call(arguments, 1))

    # Ensure both functions have the same unique id so that jQuery will accept
    # callback when unbinding closure.
    closure.guid = callback.guid = ($.guid += 1)

    $(this).bind(event, closure)
    this

  # Public: Unsubscribes a callback from an event. The callback will no longer
  # be called when the event is published.
  #
  # event    - A String event name.
  # callback - A callback function to be removed.
  #
  # Examples
  #
  #   callback = (msg) -> console.log(msg)
  #   instance.subscribe('annotation:save', callback)
  #   instance.publish('annotation:save', ['Hello World'])
  #   # => Outputs "Hello World"
  #
  #   instance.unsubscribe('annotation:save', callback)
  #   instance.publish('annotation:save', ['Hello Again'])
  #   # => No output.
  #
  # Returns itself.
  unsubscribe: ->
    $(this).unbind.apply($(this), arguments)
    this

  # Public: Alias for subscribe
  on: -> this.subscribe(arguments...)

  # Public: Alias for unsubscribe
  off: -> this.unsubscribe(arguments...)

  # Public: Alias for trigger
  trigger: -> this.publish(arguments...)

  # Public: Like subscribe, but unsubscribes automatically at first callback.
  once: (event, callback, context) ->
    closure = =>
      this.unsubscribe event, closure
      callback.apply(context, arguments)
    this.subscribe event, closure, context


module.exports = Evented