Events = require('../events')
Util = require('../util')
Widget = require('../widget')
Promise = Util.Promise
$ = Util.$
_t = Util.TranslationString

ns = 'annotator-editor'

# Public: Creates an element for editing annotations.
class Editor extends Widget

  # Classes to toggle state.
  classes:
    hide: 'annotator-hide'
    focus: 'annotator-focus'

  # HTML template for @element.
  html: """
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
    document: Util.getGlobal().document
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
    @options = $.extend(true, {}, @options, options)

    @fields = []
    @annotation = {}
    @widget = $(@html).get(0)

    if @options.defaultFields
      this.addField({
        type: 'textarea',
        label: _t('Comments') + '\u2026'
        load: (field, annotation) ->
          $(field).find('textarea').val(annotation.text || '')
        submit: (field, annotation) ->
          annotation.text = $(field).find('textarea').val()
      })

  configure: ({@core}) ->
    Object.defineProperty(@core, 'editor', {
      configurable: true
      get: =>
        # FIXME: This is a deprecation warning which suggests an alternative
        # method which also triggers a deprecation warning. We need to discuss a
        # better method of tying plugins like Tags, Permissions, etc, into the
        # Editor.
        Util.deprecationWarning("The Editor is now an optional plugin, and
                                 plugins should not refer to it using
                                 annotator.editor! Please use
                                 annotator.plugins.Editor instead.")
        this
    })

  pluginInit: ->
    $(@widget).appendTo(@options.document.body)
    .on("submit.#{ns}", 'form', this._onFormSubmit)
    .on("click.#{ns}", '.annotator-save', this._onSaveClick)
    .on("click.#{ns}", '.annotator-cancel', this._onCancelClick)
    .on("mouseover.#{ns}", '.annotator-cancel', this._onCancelMouseover)
    .on("keydown.#{ns}", 'textarea', this._onTextareaKeydown)
    this.listenTo(@core, 'beforeAnnotationCreated', this._editAnnotation)
    this.listenTo(@core, 'beforeAnnotationUpdated', this._editAnnotation)

  destroy: ->
    this.stopListening()
    $(@widget).off(".#{ns}")
    super

  # Public: Show the editor.
  #
  # Returns nothing.
  show: ->
    if @core.interactionPoint?
      $(@widget).css({
        top: @core.interactionPoint.top,
        left: @core.interactionPoint.left
      })

    $(@widget)
    .removeClass(@classes.hide)
    .find('.annotator-save')
    .addClass(@classes.focus)

    # invert if necessary
    this.checkOrientation()

    # give main textarea focus
    $(@widget).find(":input:first").focus()

    this._setupDraggables()

  # Public: Hide the editor.
  #
  # Returns nothing.
  hide: ->
    $(@widget).addClass(@classes.hide)

  # Public: Returns true if the editor is currently displayed, false otherwise.
  #
  # Examples
  #
  #   editor.show()
  #   editor.isShown() # => true
  #
  #   editor.hide()
  #   editor.isShown() # => false
  #
  # Returns true if the viewer is visible.
  isShown: ->
    not $(@widget).hasClass(@classes.hide)

  # Public: Load an annotation into the editor and display it.
  #
  # annotation - An annotation Object to display for editing.
  #
  # Returns nothing.
  load: (annotation) =>
    @annotation = annotation

    for field in @fields
      field.load(field.element, @annotation)

    this.show()

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
      when 'input', 'checkbox' then input = $('<input />')
      when 'select' then input = $('<select />')

    element.append(input)

    input.attr({
      id: field.id
      placeholder: field.label
    })

    if field.type == 'checkbox'
      input[0].type = 'checkbox'
      element.addClass('annotator-checkbox')
      element.append($('<label />', {for: field.id, html: field.label}))

    $(@widget).find('ul:first').append(element)

    @fields.push field

    field.element

  checkOrientation: ->
    super

    list = $(@widget).find('ul')
    controls = $(@widget).find('.annotator-controls')

    if $(@widget).hasClass(@classes.invert.y)
      controls.insertBefore(list)
    else if controls.is(':first-child')
      controls.insertAfter(list)

    this

  # Event callback: called when a user clicks the editor form (by pressing
  # return, for example).
  #
  # Returns nothing
  _onFormSubmit: (event) =>
    Util.preventEventDefault event
    this.submit()

  # Event callback: called when a user clicks the editor's save button.
  #
  # Returns nothing
  _onSaveClick: (event) =>
    Util.preventEventDefault event
    this.submit()

  # Event callback: called when a user clicks the editor's cancel button.
  #
  # Returns nothing
  _onCancelClick: (event) =>
    Util.preventEventDefault event
    this.cancel()

  # Event callback: called when a user mouses over the editor's cancel button.
  #
  # Returns nothing
  _onCancelMouseover: =>
    $(@widget).find('.' + @classes.focus).removeClass(@classes.focus)

  # Event callback: listens for the following special keypresses.
  # - escape: Hides the editor
  # - enter:  Submits the editor
  #
  # event - A keydown Event object.
  #
  # Returns nothing
  _onTextareaKeydown: (event) =>
    if event.which is 27 # "Escape" key => abort.
      this.cancel()
    else if event.which is 13 and !event.shiftKey
      # If "return" was pressed without the shift key, we're done.
      this.submit()

  # Event callback: called as an annotation is being created or updated.
  _editAnnotation: (annotation) =>
    return new Promise((resolve, reject) =>
      @dfd = {resolve, reject}
      this.load(annotation)
    )

  # Sets up mouse events for resizing and dragging the editor window.
  # window events are bound only when needed and throttled to only update
  # the positions at most 60 times a second.
  #
  # Returns nothing.
  _setupDraggables: ->
    $(@widget).find('.annotator-resize').remove()

    # Find the first/last item element depending on orientation
    if $(@widget).hasClass(@classes.invert.y)
      cornerItem = $(@widget).find('.annotator-item:last')
    else
      cornerItem = $(@widget).find('.annotator-item:first')

    if cornerItem
      $('<span class="annotator-resize"></span>').appendTo(cornerItem)

    mousedown = null
    classes   = @classes
    editor    = $(@widget)
    textarea  = null
    resize    = editor.find('.annotator-resize')
    controls  = editor.find('.annotator-controls')
    throttle  = false

    # coffeelint: disable=missing_fat_arrows
    onMousedown = (event) ->
      if event.target == this
        mousedown = {
          element: this
          top: event.pageY
          left: event.pageX
        }

        # Find the first text area if there is one.
        textarea = editor.find('textarea:first')

        $(window).bind({
          'mouseup.annotator-editor-resize': onMouseup
          'mousemove.annotator-editor-resize': onMousemove
        })
        event.preventDefault()
    # coffeelint: enable=missing_fat_arrows

    onMouseup = ->
      mousedown = null
      $(window).unbind '.annotator-editor-resize'

    onMousemove = (event) ->
      if mousedown and throttle == false
        diff = {
          top: event.pageY - mousedown.top
          left: event.pageX - mousedown.left
        }

        if mousedown.element == resize[0]
          height = textarea.outerHeight()
          width  = textarea.outerWidth()

          directionX = if editor.hasClass(classes.invert.x) then -1 else  1
          directionY = if editor.hasClass(classes.invert.y) then  1 else -1

          textarea.height height + (diff.top  * directionY)
          textarea.width  width  + (diff.left * directionX)

          # Only update the mousedown object if the dimensions
          # have changed, otherwise they have reached their minimum
          # values.
          mousedown.top  = event.pageY unless textarea.outerHeight() == height
          mousedown.left = event.pageX unless textarea.outerWidth()  == width

        else if mousedown.element == controls[0]
          editor.css({
            top: parseInt(editor.css('top'), 10) + diff.top
            left: parseInt(editor.css('left'), 10) + diff.left
          })

          mousedown.top  = event.pageY
          mousedown.left = event.pageX

        throttle = true
        setTimeout((-> throttle = false), 1000 / 60)

    resize.bind   'mousedown', onMousedown
    controls.bind 'mousedown', onMousedown


Events.mixin(Editor::)

# This is a core plugin (registered by default with Annotator), so we don't
# register here. If you're writing a plugin of your own, please refer to a
# non-core plugin (such as Document or Store) to see how to register your plugin
# with Annotator.

module.exports = Editor
