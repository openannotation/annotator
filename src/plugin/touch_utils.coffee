# Adds a new "tap" event to jQuery. This offers improved performance over
# click for touch devices whcih often have up to a 300ms delay before
# triggering callbacks. Instead it uses a combination of touchstart and
# touchend events to to create a fake click. It will also cancel the event
# after 300ms (to allow the user to perform a "longtap") or if the touchend
# event is triggered on a different element.
#
# Additonal options can be provided as part of the eventData object.
#
# preventDefault - If false will not call preventDefault() on the touchstart
#                  event (deafult: true).
# onTapDown      - Callback for the "touchstart" incase additonal code needs
#                  to be run such as event.stopPropagation().
# onTapUp        - Callabck for the "touchend" event, called after the main
#                  event handler.
# timeout        - Time to allow before cancelling the event (default: 300).
#
# Example
#
#   jQuery("a").bind "tap", =>
#     # This is called on "touchend" on the same element.
#
#   options =
#     preventDefault: false
#     onTapDown: (event) -> event.stopPropagation()
#   jQuery(doument).delegate "button", "tap", options, =>
#     # This is called on "touchend" on the same element.
jQuery.event.special.tap =
  add: (eventHandler) ->
    data = eventHandler.data = eventHandler.data or {}
    context = this

    onTapStart = (event) ->
      event.preventDefault() unless data.preventDefault is false
      data.onTapDown.apply(this, arguments) if data.onTapDown

      data.event = event
      data.touched = setTimeout ->
        data.touched = null
      , data.timeout or 300
      jQuery(document).bind(touchend: onTapEnd, mouseup: onTapEnd)

    onTapEnd = (event) ->
      if data.touched?
        clearTimeout(data.touched)
        if event.target is context or jQuery.contains(context, event.target)
          handler = eventHandler.origHandler or eventHandler.handler
          handler.call(this, data.event)
        data.touched = null

      data.onTapUp.apply(this, arguments) if data.onTapUp

      jQuery(document).unbind(touchstart: onTapEnd, mousedown: onTapEnd)

    data.tapHandlers = touchstart: onTapStart, mousedown: onTapStart
    if eventHandler.selector
      jQuery(context).delegate(eventHandler.selector, data.tapHandlers)
    else
      jQuery(context).bind(data.tapHandlers)

  remove: (eventHandler) ->
    jQuery(this).unbind(eventHandler.data.tapHandlers)

# Add support for "touch" events.
Annotator.Delegator.natives.push("touchstart", "touchmove", "touchend", "tap")

Annotator.Plugin.Touch.utils = do ->
  # Pinched from Paul Irish's blog.
  # See: http://paulirish.com/2011/requestanimationframe-for-smart-animating/
  vendors = ['ms', 'moz', 'webkit', 'o']

  requestAnimationFrame = window.requestAnimationFrame
  cancelAnimationFrame  = window.cancelAnimationFrame

  for prefix in vendors when !requestAnimationFrame
    requestAnimationFrame = window["#{prefix}RequestAnimationFrame"]
    cancelAnimationFrame  = window["#{prefix}CancelAnimationFrame"] or
                            window["#{prefix}CancelRequestAnimationFrame"]

  unless requestAnimationFrame
    lastTime = 0
    requestAnimationFrame = (callback, element) ->
      currTime   = new Date().getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      lastTime   = currTime + timeToCall
      window.setTimeout((-> callback(currTime + timeToCall)), timeToCall)

  unless cancelAnimationFrame
    cancelAnimationFrame = (id) -> clearTimeout(id)

  {
    # Public: Cross browser compatibile version of requestAnimationFrame().
    #
    # callback - A function to be called when the next frame is available.
    #
    # Examples
    #
    #   var id = utils.requestAnimationFrame ->
    #     doSomethingCool()
    #
    # Returns a id to cancel the request.
    requestAnimationFrame: requestAnimationFrame

    # Public: Cross browser compatibile version of cancelAnimationFrame().
    #
    # id - A request id.
    #
    # Examples
    #
    #   id = utils.requestAnimationFrame ->
    #     thisWillNeverBeCalled()
    #   utils.cancelAnimationFrame(id)
    #
    # Returns nothing.
    cancelAnimationFrame:  cancelAnimationFrame

    # Public: Defer a callback until the next available moment. This is useful
    # for queuing a function to run in the near future for example to run a
    # function after the current callback stack has run.
    #
    # fn - A function to defer.
    #
    # Examples
    #
    #   annotator.editor.on "show", ->
    #     # Hide viewer after rest of "show" events have fired.
    #     utils.nextTick(annotator.viewer.show)
    #
    # Returns nothing.
    nextTick: (fn) -> setTimeout(fn, 0)
  }
