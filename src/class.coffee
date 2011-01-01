unless jQuery?.fn?.jquery
  console.error("Annotator requires jQuery: have you included lib/vendor/jquery.js?")

unless _?.VERSION
  console.error("Annotator requires Underscore.js: have you included lib/vendor/underscore.js?")

unless JSON and JSON.parse and JSON.stringify
  console.error("Annotator requires a JSON implementation: have you included lib/vendor/json2.js?")

$ = jQuery

class Delegator
  events: {}

  constructor: (element, options) ->
    @options = $.extend(@options, options)
    @element = element

  addEvents: ->
    for sel, functionName of @events
      [selector..., event] = sel.split ' '
      this.addEvent selector.join(' '), event, functionName

  addEvent: (bindTo, event, functionName) ->
    closure = => this[functionName].apply(this, arguments)

    isBlankSelector = typeof bindTo is 'string' and bindTo.replace(/\s+/g, '') is ''

    bindTo = @element if isBlankSelector

    if typeof bindTo is 'string'
      $(@element).delegate bindTo, event, closure
    else
      $(bindTo).bind event, closure

this.Delegator = Delegator

# PluginFactory. Make a jQuery plugin out of a Class.
$.plugin = (name, object) ->
  # create a new plugin with the given name
  $.fn[name] = (options) ->

    args = Array::slice.call(arguments, 1)
    this.each ->

      # check the data() cache, if it's there we'll call the method requested
      instance = $.data(this, name)
      if instance
        options && instance[options].apply(instance, args)
      else
        instance = new object(this, options)
        $.data(this, name, instance)
