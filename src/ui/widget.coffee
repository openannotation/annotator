Delegator = require('../delegator')
Util = require('../util')

$ = Util.$


# Public: Base class for the Editor and Viewer elements. Contains methods that
# are shared between the two.
class Widget extends Delegator

  # Classes used to alter the widgets state.
  classes:
    hide: 'annotator-hide'
    invert:
      x: 'annotator-invert-x'
      y: 'annotator-invert-y'

  template: """<div></div>"""

  # Default options for the plugin.
  options:
    # A CSS selector or Element to append the Widget to.
    appendTo: 'body'

  # Public: Creates a new Widget instance.
  #
  # Returns a new Widget instance.
  constructor: (options) ->
    super $(@template)[0], options
    @classes = $.extend {}, Widget.prototype.classes, @classes
    @options = $.extend {}, Widget.prototype.options, @options

  # Public: Destroy the Widget, unbinding all events and removing the element.
  #
  # Returns nothing.
  destroy: ->
    super
    @element.remove()

  # Public: Renders the widget
  render: ->
    @element.appendTo(@options.appendTo)

  # Public: Show the widget.
  #
  # Returns nothing.
  show: ->
    @element.removeClass(@classes.hide)

    # invert if necessary
    this.checkOrientation()

  # Public: Hide the widget.
  #
  # Returns nothing.
  hide: ->
    $(@element).addClass(@classes.hide)

  # Public: Returns true if the widget is currently displayed, false otherwise.
  #
  # Examples
  #
  #   widget.show()
  #   widget.isShown() # => true
  #
  #   widget.hide()
  #   widget.isShown() # => false
  #
  # Returns true if the widget is visible.
  isShown: ->
    not $(@element).hasClass(@classes.hide)

  checkOrientation: ->
    this.resetOrientation()

    window   = $(Util.getGlobal())
    widget   = @element.children(":first")
    offset   = widget.offset()
    viewport = {
      top: window.scrollTop(),
      right: window.width() + window.scrollLeft()
    }
    current = {
      top: offset.top
      right: offset.left + widget.width()
    }

    if (current.top - viewport.top) < 0
      this.invertY()

    if (current.right - viewport.right) > 0
      this.invertX()

    this

  # Public: Resets orientation of widget on the X & Y axis.
  #
  # Examples
  #
  #   widget.resetOrientation() # Widget is original way up.
  #
  # Returns itself for chaining.
  resetOrientation: ->
    @element.removeClass(@classes.invert.x).removeClass(@classes.invert.y)
    this

  # Public: Inverts the widget on the X axis.
  #
  # Examples
  #
  #   widget.invertX() # Widget is now right aligned.
  #
  # Returns itself for chaining.
  invertX: ->
    @element.addClass(@classes.invert.x)
    this

  # Public: Inverts the widget on the Y axis.
  #
  # Examples
  #
  #   widget.invertY() # Widget is now upside down.
  #
  # Returns itself for chaining.
  invertY: ->
    @element.addClass(@classes.invert.y)
    this

  # Public: Find out whether or not the widget is currently upside down
  #
  # Returns a boolean: true if the widget is upside down
  isInvertedY: ->
    @element.hasClass(@classes.invert.y)

  # Public: Find out whether or not the widget is currently right aligned
  #
  # Returns a boolean: true if the widget is right aligned
  isInvertedX: ->
    @element.hasClass(@classes.invert.x)


exports.Widget = Widget
