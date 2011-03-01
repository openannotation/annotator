class Delegator
  events: {}

  constructor: (element, options) ->
    @options = $.extend(true, {}, @options, options)
    @element = $(element)

    this.on = this.subscribe
    this.addEvents()

  addEvents: ->
    for sel, functionName of @events
      [selector..., event] = sel.split ' '
      this.addEvent selector.join(' '), event, functionName

  addEvent: (bindTo, event, functionName) ->
    closure = => this[functionName].apply(this, arguments)

    isBlankSelector = typeof bindTo is 'string' and bindTo.replace(/\s+/g, '') is ''

    bindTo = @element if isBlankSelector

    if typeof bindTo is 'string'
      @element.delegate bindTo, event, closure
    else
      $(bindTo).bind event, closure

  publish: () ->
    @element.trigger.apply @element, arguments

  subscribe: (event, callback) ->
    closure = -> callback.apply(this, [].slice.call(arguments, 1))
    @element.bind event, closure

  unsubscribe: -> 
    @element.unbind.apply @element, arguments
