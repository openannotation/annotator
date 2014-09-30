Widget = require('./widget').Widget
Util = require('../util')

$ = Util.$
_t = Util.TranslationString
Promise = Util.Promise

NS = "annotator-editor"


# Public: Creates an element for editing annotations.
class Editor extends Widget

  # Classes to toggle state.
  classes:
    hide: 'annotator-hide'
    focus: 'annotator-focus'

  # HTML template for @element.
  template:
    """
    <div class="annotator-outer annotator-editor annotator-hide">
      <form class="annotator-widget">
        <ul class="annotator-listing"></ul>
        <div class="annotator-controls">
          <a href="#cancel" class="annotator-cancel">#{_t('Cancel')}</a>
          <a href="#save"
             class="annotator-save annotator-focus">#{_t('Save')}</a>
        </div>
      </form>
    </div>
    """

  # Configuration options
  options:
    defaultFields: true # Add the default field(s) to the editor.

  # Public: Creates an instance of the Editor object.
  #
  # options - An Object literal containing options.
  #
  # Examples
  #
  #   # Creates a new editor, adds a custom field and
  #   # loads an annotation for editing.
  #   editor = new Annotator.Editor
  #   editor.addField({
  #     label: 'My custom input field',
  #     type:  'textarea'
  #     load:  someLoadCallback
  #     save:  someSaveCallback
  #   })
  #   editor.load(annotation)
  #
  # Returns a new Editor instance.
  constructor: (options) ->
    super

    @fields = []
    @annotation = {}

    if @options.defaultFields
      this.addField({
        type: 'textarea',
        label: _t('Comments') + '\u2026'
        load: (field, annotation) ->
          $(field).find('textarea').val(annotation.text || '')
        submit: (field, annotation) ->
          annotation.text = $(field).find('textarea').val()
      })

    @element
      .on("submit.#{NS}", 'form', (e) => this._onFormSubmit(e))
      .on("click.#{NS}", '.annotator-save', (e) => this._onSaveClick(e))
      .on("click.#{NS}", '.annotator-cancel', (e) => this._onCancelClick(e))
      .on("mouseover.#{NS}", '.annotator-cancel',
          (e) => this._onCancelMouseover(e))
      .on("keydown.#{NS}", 'textarea', (e) => this._onTextareaKeydown(e))

    this.render()

  destroy: ->
    @element.off(".#{NS}")
    super

  # Public: Show the editor.
  #
  # position - An Object specifying the position in which to show the editor
  #            (optional).
  #
  # Examples
  #
  #   editor.show()
  #   editor.hide()
  #   editor.show({top: '100px', left: '80px'})
  #
  # Returns nothing.
  show: (position = null) ->
    if position?
      @element.css({
        top: position.top,
        left: position.left
      })

    @element
    .find('.annotator-save')
    .addClass(@classes.focus)

    super

    # give main textarea focus
    @element.find(":input:first").focus()

    this._setupDraggables()

  # Public: Load an annotation into the editor and display it.
  #
  # annotation - An annotation Object to display for editing.
  # position - An Object specifying the position in which to show the editor
  #            (optional).
  #
  # Returns a Promise that is resolved when the editor is submitted, or rejected
  # if editing is cancelled.
  load: (annotation, position = null) =>
    @annotation = annotation

    for field in @fields
      field.load(field.element, @annotation)

    return new Promise((resolve, reject) =>
      @dfd = {resolve, reject}
      this.show(position)
    )

  # Public: Submits the editor and saves any changes made to the annotation.
  #
  # Returns nothing.
  submit: ->
    for field in @fields
      field.submit(field.element, @annotation)
    if @dfd?
      @dfd.resolve()

    this.hide()

  # Public: Cancels the editing process, discarding any edits made to the
  # annotation.
  #
  # Returns itself.
  cancel: ->
    if @dfd?
      @dfd.reject('editing cancelled')

    this.hide()

  # Public: Adds an addional form field to the editor. Callbacks can be provided
  # to update the view and anotations on load and submission.
  #
  # options - An options Object. Options are as follows:
  #           id     - A unique id for the form element will also be set as the
  #                    "for" attrubute of a label if there is one. Defaults to
  #                    a timestamp. (default: "annotator-field-{timestamp}")
  #           type   - Input type String. One of "input", "textarea",
  #                    "checkbox", "select" (default: "input")
  #           label  - Label to display either in a label Element or as place-
  #                    holder text depending on the type. (default: "")
  #           load   - Callback Function called when the editor is loaded with a
  #                    new annotation. Recieves the field <li> element and the
  #                    annotation to be loaded.
  #           submit - Callback Function called when the editor is submitted.
  #                    Recieves the field <li> element and the annotation to be
  #                    updated.
  #
  # Examples
  #
  #   # Add a new input element.
  #   editor.addField({
  #     label: "Tags",
  #
  #     # This is called when the editor is loaded use it to update your input.
  #     load: (field, annotation) ->
  #       # Do something with the annotation.
  #       value = getTagString(annotation.tags)
  #       $(field).find('input').val(value)
  #
  #     # This is called when the editor is submitted use it to retrieve data
  #     # from your input and save it to the annotation.
  #     submit: (field, annotation) ->
  #       value = $(field).find('input').val()
  #       annotation.tags = getTagsFromString(value)
  #   })
  #
  #   # Add a new checkbox element.
  #   editor.addField({
  #     type: 'checkbox',
  #     id: 'annotator-field-my-checkbox',
  #     label: 'Allow anyone to see this annotation',
  #     load: (field, annotation) ->
  #       # Check what state of input should be.
  #       if checked
  #         $(field).find('input').attr('checked', 'checked')
  #       else
  #         $(field).find('input').removeAttr('checked')

  #     submit: (field, annotation) ->
  #       checked = $(field).find('input').is(':checked')
  #       # Do something.
  #   })
  #
  # Returns the created <li> Element.
  addField: (options) ->
    field = $.extend({
      id: 'annotator-field-' + Util.uuid()
      type: 'input'
      label: ''
      load: ->
      submit: ->
    }, options)

    input = null
    element = $('<li class="annotator-item" />')
    field.element = element[0]

    switch (field.type)
      when 'textarea'          then input = $('<textarea />')
      when 'checkbox' then input = $('<input type="checkbox" />')
      when 'input' then input = $('<input />')
      when 'select' then input = $('<select />')

    element.append(input)

    input.attr({
      id: field.id
      placeholder: field.label
    })

    if field.type == 'checkbox'
      element.addClass('annotator-checkbox')
      element.append($('<label />', {for: field.id, html: field.label}))

    @element.find('ul:first').append(element)

    @fields.push field

    field.element

  checkOrientation: ->
    super

    list = @element.find('ul')
    controls = @element.find('.annotator-controls')

    if @element.hasClass(@classes.invert.y)
      controls.insertBefore(list)
    else if controls.is(':first-child')
      controls.insertAfter(list)

    this

  # Event callback: called when a user clicks the editor form (by pressing
  # return, for example).
  #
  # Returns nothing
  _onFormSubmit: (event) ->
    Util.preventEventDefault event
    this.submit()

  # Event callback: called when a user clicks the editor's save button.
  #
  # Returns nothing
  _onSaveClick: (event) ->
    Util.preventEventDefault event
    this.submit()

  # Event callback: called when a user clicks the editor's cancel button.
  #
  # Returns nothing
  _onCancelClick: (event) ->
    Util.preventEventDefault event
    this.cancel()

  # Event callback: called when a user mouses over the editor's cancel button.
  #
  # Returns nothing
  _onCancelMouseover: ->
    @element.find('.' + @classes.focus).removeClass(@classes.focus)

  # Event callback: listens for the following special keypresses.
  # - escape: Hides the editor
  # - enter:  Submits the editor
  #
  # event - A keydown Event object.
  #
  # Returns nothing
  _onTextareaKeydown: (event) ->
    if event.which is 27 # "Escape" key => abort.
      this.cancel()
    else if event.which is 13 and !event.shiftKey
      # If "return" was pressed without the shift key, we're done.
      this.submit()

  # Sets up mouse events for resizing and dragging the editor window.
  #
  # Returns nothing.
  _setupDraggables: ->
    @_resizer?.destroy()
    @_mover?.destroy()

    @element.find('.annotator-resize').remove()

    # Find the first/last item element depending on orientation
    if @element.hasClass(@classes.invert.y)
      cornerItem = @element.find('.annotator-item:last')
    else
      cornerItem = @element.find('.annotator-item:first')

    if cornerItem
      $('<span class="annotator-resize"></span>').appendTo(cornerItem)

    controls = @element.find('.annotator-controls')[0]
    textarea = @element.find('textarea:first')[0]
    resizeHandle = @element.find('.annotator-resize')[0]

    @_resizer = Resizer(textarea, resizeHandle, {
      invertedX: => @element.hasClass(@classes.invert.x)
      invertedY: => @element.hasClass(@classes.invert.y)
    })

    @_mover = Mover(@element[0], controls)


# DragTracker for a callback to track changes made to the position of a
# draggable "handle" element.
#
# handle - A DOM element to make draggable
# callback - Callback function
#
# Callback arguments:
#
# delta - An Object with two properties, "x" and "y", denoting the amount the
#         mouse has moved since the last (tracked) call.
#
# Callback returns: Boolean indicating whether to track the last movement.
#
DragTracker = (handle, callback) ->

  lastPos = null
  throttled = false

  # Event handler for mousemove
  mouseMove = (e) ->
    if throttled or lastPos == null
      return

    delta = {
      y: e.pageY - lastPos.top
      x: e.pageX - lastPos.left
    }

    trackLastMove = true
    # The callback function can return false to indicate that the tracker
    # shouldn't keep updating the last position. This can be used to implement
    # "walls" beyond which (for example) resizing has no effect.
    if typeof callback == 'function'
      trackLastMove = callback(delta)

    if trackLastMove != false
      lastPos = {
        top: e.pageY
        left: e.pageX
      }

    # Throttle repeated mousemove events
    throttled = true
    setTimeout((-> throttled = false), 1000 / 60)

  # Event handler for mouseup
  mouseUp = (e) ->
    lastPos = null
    $(handle.ownerDocument)
      .off('mouseup', mouseUp)
      .off('mousemove', mouseMove)

  # Event handler for mousedown -- starts drag tracking
  mouseDown = (e) ->
    if e.target != handle
      return

    lastPos = {
      top: e.pageY
      left: e.pageX
    }

    $(handle.ownerDocument)
      .on('mouseup', mouseUp)
      .on('mousemove', mouseMove)

    e.preventDefault()

  # Public: turn off drag tracking for this DragTracker object.
  destroy = ->
    $(handle).off('mousedown', mouseDown)

  $(handle).on('mousedown', mouseDown)

  return {destroy: destroy}


# Resizer is a component that uses a DragTracker under the hood to track the
# dragging of a handle element, using that motion to resize another element.
#
# element - DOM Element to resize
# handle - DOM Element to use as a resize handle
# options - Object of options.
#
# Available options:
#
# invertedX - If this option is defined as a function, and that function returns
#             a truthy value, the horizontal sense of the drag will be inverted.
#             Useful if the drag handle is at the left of the element, and so
#             dragging left means "grow the element"
# invertedY - If this option is defined as a function, and that function returns
#             a truthy value, the vertical sense of the drag will be inverted.
#             Useful if the drag handle is at the bottom of the element, and so
#             dragging down means "grow the element"
Resizer = (element, handle, options) ->

  $el = $(element)

  # Translate the delta supplied by DragTracker into a delta that takes account
  # of the invertedX and invertedY callbacks if defined.
  translate = (delta) ->
    directionX = 1
    directionY = -1

    if typeof options?.invertedX == 'function' and options.invertedX()
      directionX = -1
    if typeof options?.invertedY == 'function' and options.invertedY()
      directionY = 1

    return {
      x: delta.x * directionX
      y: delta.y * directionY
    }

  # Callback for DragTracker
  resize = (delta) ->
    height = $el.height()
    width = $el.width()

    translated = translate(delta)

    if Math.abs(translated.x) > 0
      $el.width(width + translated.x)
    if Math.abs(translated.y) > 0
      $el.height(height + translated.y)

    # Did the element dimensions actually change? If not, then we've reached the
    # minimum size, and we shouldn't track
    return $el.height() != height or $el.width() != width

  # We return the DragTracker object in order to expose its methods.
  return DragTracker(handle, resize)


# Mover is a component that uses a DragTracker under the hood to track the
# dragging of a handle element, using that motion to move another element.
#
# element - DOM Element to move
# handle - DOM Element to use as a move handle
#
Mover = (element, handle) ->

  move = (delta) ->
    $(element).css({
      top: parseInt($(element).css('top'), 10) + delta.y
      left: parseInt($(element).css('left'), 10) + delta.x
    })

  # We return the DragTracker object in order to expose its methods.
  return DragTracker(handle, move)


exports.DragTracker = DragTracker
exports.Editor = Editor
exports.Mover = Mover
exports.Resizer = Resizer
