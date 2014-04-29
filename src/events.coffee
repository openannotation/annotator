BackboneEvents = require('backbone-events-standalone')
Promise = require('./util').Promise

eventSplitter = /\s+/

# Fires events as `trigger` normally would, but assumes that some of the
# `return` values from the events may be promises, and and returns a promise
# when all of the events are resolved.
#
# This code is heavily inspired by the bookshelf project's "trigger-then"
# package: https://github.com/bookshelf/trigger-then
#
triggerThen = (name, args...) ->
  return Promise.all([]) unless @_events
  dfds = []
  if eventSplitter.test(name)
    names = name.split(eventSplitter)
    for name in names
      dfds.push(triggerThen.apply(this, [name, args...]))
    return Promise.all(dfds)
  else
    events = @_events[name]
  allEvents = @_events.all

  # Wrap in a try/catch to reject the promise if any errors are thrown within
  # the handlers.
  try
    if events
      results = (ev.callback.apply(ev.ctx, args) for ev in events)
      dfds = dfds.concat(results)
    if allEvents
      results = (ev.callback.apply(ev.ctx, [name, args...]) for ev in allEvents)
      dfds = dfds.concat(results)
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
