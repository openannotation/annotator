# Wrapper around the Annotator.Viewer class. Augments the interface with
# tap friendly buttons and touch event handlers. Rather than creating a new
# class or extending the Annotator.Viewer class we use the wrapper to
# change the current interface without having to heavily monkey patch the
# Annotator core.
class Annotator.Plugin.Touch.Viewer extends Annotator.Delegator
  jQuery = Annotator.$

  # Events bound to the element.
  events:
    ".annotator-item tap":   "_onTap"
    ".annotator-edit tap":   "_onEdit"
    ".annotator-delete tap": "_onDelete"

  # Sets up the wrapper and instance methods.
  #
  # viewer  - An instance of Annotator.Viewer.
  # options - An object of instance options.
  #
  # Returns nothing.
  constructor: (@viewer, options) ->
    super @viewer.element[0], options

    @element.unbind("click")
    @element.addClass("annotator-touch-widget annotator-touch-viewer")

    @on("load", @_onLoad)

  # Public: Hides edit controls for all displayed annotations.
  #
  # Examples
  #
  #   jQuery(document).click ->
  #     viewer.hideAllControls()
  #
  # Returns itself.
  hideAllControls: ->
    @element.find(".annotator-item").removeClass(@viewer.classes.showControls)
    this

  # Event handler called when a field is loaded. Augments the field with
  # additonal classes and event handlers.
  #
  # Returns nothing.
  _onLoad: =>
    controls = @element.find(".annotator-controls")
    controls.toggleClass("annotator-controls annotator-touch-controls")
    controls.find("button").addClass("annotator-button")

  # Callback event called when a field is tapped.
  #
  # event - A jQuery.Event touchend event.
  #
  # Returns nothing.
  _onTap: (event) ->
    target = jQuery(event.currentTarget)
    isVisible = target.hasClass(@viewer.classes.showControls)
    @hideAllControls()
    target.addClass(@viewer.classes.showControls) unless isVisible

  # Callback event called when an edit button is tapped.
  #
  # event - A jQuery.Event touchend event.
  #
  # Returns nothing.
  _onEdit: (event) ->
    event.preventDefault()
    @viewer.onEditClick(event)

  # Callback event called when an delete button is tapped.
  #
  # event - A jQuery.Event touchend event.
  #
  # Returns nothing.
  _onDelete: (event) ->
    event.preventDefault()
    @viewer.onDeleteClick(event)
