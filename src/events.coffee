BackboneEvents = require('backbone-events-standalone')
Promise = require('./util').Promise

push = Array::push
slice = Array::slice
eventSplitter = /\s+/

# Fires events as `trigger` normally would, but assumes that some of the
# `return` values from the events may be promises, and and returns a promise
# when all of the events are resolved.
#
# This code is heavily inspired by the bookshelf project's "trigger-then"
# package: https://github.com/bookshelf/trigger-then
triggerThen = (name) ->
  return Promise.all([]) unless @_events
  args = slice.call(arguments, 1)
  dfds = []
  evts = undefined
  if eventSplitter.test(name)
    names = name.split(eventSplitter)
    for name in names
      Array::push.call(dfds, triggerThen.apply(this, [name].concat(args)))
    return Promise.all(dfds)
  else
    evts = @_events[name]
  allEvents = @_events.all

  # Wrap in a try/catch to reject the promise if any errors are thrown within
  # the handlers.
  try
    if evts
      push.apply(dfds, ev.callback.apply(ev.ctx, args) for ev in evts)
    if allEvents
      push.apply(dfds, ev.callback.apply(ev.ctx, arguments) for ev in allEvents)
  catch e
    return Promise.reject(e)
  Promise.all(dfds)

Events = {}

for own k, v of BackboneEvents when k != 'BackboneEvents'
  Events[k] = v

Events.triggerThen = triggerThen
Events.mixin = (proto) ->
  exports = [
    "on"
    "once"
    "off"
    "trigger"
    "triggerThen"
    "stopListening"
    "listenTo"
    "listenToOnce"
    "bind"
    "unbind"
  ]
  for name in exports
    proto[name] = this[name]
  this

module.exports = Events
