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
      if this.isCustomEvent(event)
        this.subscribe event, closure
      else
        $(bindTo).bind event, closure

    this

  isCustomEvent: (event) ->
    natives = """
              blur focus focusin focusout load resize scroll unload click dblclick
              mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave
              change select submit keydown keypress keyup error
              """.split(/[^a-z]+/)
    [event] = event.split('.')

    return $.inArray(event, natives) == -1

  publish: () ->
    @element.trigger.apply @element, arguments
    this

  subscribe: (event, callback) ->
    closure = -> callback.apply(this, [].slice.call(arguments, 1))
    @element.bind event, closure
    this

  unsubscribe: ->
    @element.unbind.apply @element, arguments
    this
