# Public: Base class for the Editor and Viewer elements. Contains methods that
# are shared between the two.
class Annotator.Widget extends Delegator
  # Classes used to alter the widgets state.
  classes:
    hide: 'annotator-hide'
    invert:
      x: 'annotator-invert-x'
      y: 'annotator-invert-y'
  
  # Public: Creates a new Widget instance.
  #
  # element - The Element that represents the widget in the DOM.
  # options - An Object literal of options.
  #
  # Examples
  #
  #   element = document.createElement('div')
  #   widget  = new Annotator.Widget(element)
  #
  # Returns a new Widget instance.
  constructor: (element, options) ->
    super
    @classes = $.extend Annotator.Widget.prototype.classes, @classes

  # Public: Inverts the widget on the X axis.
  #
  # Examples
  #
  #   widget.invertX() # Widget is now right aligned.
  #
  # Returns itself for chaining.
  invertX: ->
    @element.addClass @classes.invert.x
    this

  # Public: Inverts the widget on the Y axis.
  #
  # Examples
  #
  #   widget.invertY() # Widget is now upside down.
  #
  # Returns itself for chaining.
  invertY: ->
    @element.addClass @classes.invert.y
    this

  # Public: Resets orientation of widget on the X axis.
  #
  # Examples
  #
  #   widget.resetX() # Widget is now left aligned.
  #
  # Returns itself for chaining.
  resetX: ->
    @element.removeClass(@classes.invert.x)
    this

  # Public: Resets orientation of widget on the Y axis.
  #
  # Examples
  #
  #   widget.resetX() # Widget is original way up.
  #
  # Returns itself for chaining.
  resetY: ->
    @element.removeClass(@classes.invert.y)
    this
