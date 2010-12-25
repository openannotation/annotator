$ = jQuery

class Delegator
  events: {}

  constructor: (element, options) ->
    @options = $.extend(@options, options)
    @element = element

  addEvents: () ->
    for sel, functionName of @events
      [selector..., event] = sel.split ' '
      this.addEvent selector.join(' '), event, functionName
      # console.log selector.join(' '), '>', event, '>', functionName

  addEvent: (bindTo, event, functionName) ->
    closure = () => this[functionName].apply(this, arguments)

    isBlankSelector = typeof bindTo is 'string' and bindTo.replace(/\s+/g, '') is ''

    bindTo = @element if isBlankSelector

    if typeof bindTo is 'string'
      # console.log "binding selector #{bindTo} for event #{event}:", closure
      $(@element).delegate bindTo, event, closure
    else
      # console.log "binding element ", bindTo, " for event #{event}:", closure
      $(bindTo).bind event, closure

this.Delegator = Delegator

# PluginFactory. Make a jQuery plugin out of a Class.
$.plugin = (name, object) ->
  # create a new plugin with the given name
  $.fn[name] = (options) ->

    args = Array::slice.call(arguments, 1)
    this.each () ->

      # check the data() cache, if it's there we'll call the method requested
      instance = $.data(this, name)
      if instance
        options && instance[options].apply(instance, args)
      else
        instance = new object(this, options)
        $.data(this, name, instance)
