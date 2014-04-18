Util = require('./util')
$ = Util.$


# Public: Base class for the Editor and Viewer elements. Contains methods that
# are shared between the two.
class Widget
  # Classes used to alter the widgets state.
  classes:
    hide: 'annotator-hide'
    invert:
      x: 'annotator-invert-x'
      y: 'annotator-invert-y'

  # Public: Creates a new Widget instance.
  #
  # Returns a new Widget instance.
  constructor: ->
    @classes = $.extend {}, Widget.prototype.classes, @classes

  # Public: Unbind the widget's events and remove its element from the DOM.
  #
  # Returns nothing.
  destroy: ->
    $(@widget).remove()

  checkOrientation: ->
    this.resetOrientation()

    window   = $(Util.getGlobal())
    widget   = $(@widget).children(":first")
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
    $(@widget).removeClass(@classes.invert.x).removeClass(@classes.invert.y)
    this

  # Public: Inverts the widget on the X axis.
  #
  # Examples
  #
  #   widget.invertX() # Widget is now right aligned.
  #
  # Returns itself for chaining.
  invertX: ->
    $(@widget).addClass(@classes.invert.x)
    this

  # Public: Inverts the widget on the Y axis.
  #
  # Examples
  #
  #   widget.invertY() # Widget is now upside down.
  #
  # Returns itself for chaining.
  invertY: ->
    $(@widget).addClass(@classes.invert.y)
    this

  # Public: Find out whether or not the widget is currently upside down
  #
  # Returns a boolean: true if the widget is upside down
  isInvertedY: ->
    $(@widget).hasClass(@classes.invert.y)

  # Public: Find out whether or not the widget is currently right aligned
  #
  # Returns a boolean: true if the widget is right aligned
  isInvertedX: ->
    $(@widget).hasClass(@classes.invert.x)


# Export the Widget object
module.exports = Widget
