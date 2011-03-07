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
