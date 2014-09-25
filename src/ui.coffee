Range = require('xpath-range').Range

Delegator = require('./delegator')
Util = require('./util')

$ = Util.$
_t = Util.TranslationString
Promise = Util.Promise

ADDER_NS = 'annotator-adder'
TEXTSELECTOR_NS = 'annotator-textselector'
VIEWER_NS = 'annotator-viewer'

ADDER_HTML =
  """
  <div class="annotator-adder annotator-hide">
    <button type="button">#{_t('Annotate')}</button>
  </div>
  """


# highlightRange wraps the DOM Nodes within the provided range with a highlight
# element of the specified class and returns the highlight Elements.
#
# normedRange - A NormalizedRange to be highlighted.
# cssClass - A CSS class to use for the highlight (default: 'annotator-hl')
#
# Returns an array of highlight Elements.
highlightRange = (normedRange, cssClass = 'annotator-hl') ->
  white = /^\s*$/

  hl = $("<span class='#{cssClass}'></span>")

  # Ignore text nodes that contain only whitespace characters. This prevents
  # spans being injected between elements that can only contain a restricted
  # subset of nodes such as table rows and lists. This does mean that there
  # may be the odd abandoned whitespace node in a paragraph that is skipped
  # but better than breaking table layouts.
  for node in normedRange.textNodes() when not white.test(node.nodeValue)
    $(node).wrapAll(hl).parent().show()[0]


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


# Adder shows and hides an annotation adder button that can be clicked on to
# create an annotation.
class Adder extends Widget
  events:
    "button click": "_onClick"
    "button mousedown": "_onMousedown"

  template: ADDER_HTML

  # Configuration options
  options:
    onCreate: null # Callback, called when the user clicks the adder when an
                   # annotation is loaded.

  constructor: (options) ->
    super

    @ignoreMouseup = false
    @annotation = null

    @document = @element[0].ownerDocument
    $(@document.body).on("mouseup.#{ADDER_NS}", this._onMouseup)
    this.render()

  destroy: ->
    super
    $(@document.body).off(".#{ADDER_NS}")

  # Public: Load an annotation and show the adder.
  #
  # annotation - An annotation Object to load.
  # position - An Object specifying the position in which to show the editor
  #            (optional).
  #
  # If the user clicks on the adder with an annotation loaded, the onCreate
  # handler will be called. In this way, the adder can serve as an intermediary
  # step between making a selection and creating an annotation.
  #
  # Returns nothing.
  load: (annotation, position = null) ->
    @annotation = annotation
    this.show(position)

  # Public: Show the adder.
  #
  # position - An Object specifying the position in which to show the editor
  #            (optional).
  #
  # Examples
  #
  #   adder.show()
  #   adder.hide()
  #   adder.show({top: '100px', left: '80px'})
  #
  # Returns nothing.
  show: (position = null) ->
    if position?
      @element.css({
        top: position.top,
        left: position.left
      })
    super

  # Event callback: called when the mouse button is depressed on the adder.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  _onMousedown: (event) ->
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    event?.preventDefault()
    # Prevent the selection code from firing when the mouse button is released
    @ignoreMouseup = true

  # Event callback: called when the mouse button is released
  #
  # event - A mouseup Event object
  #
  # Returns nothing.
  _onMouseup: (event) ->
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    # Prevent the selection code from firing when the ignoreMouseup flag is set
    if @ignoreMouseup
      event.stopImmediatePropagation()


  # Event callback: called when the adder is clicked. The click event is used as
  # well as the mousedown so that we get the :active state on the adder when
  # clicked.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  _onClick: (event) ->
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    event?.preventDefault()

    # Hide the adder
    this.hide()
    @ignoreMouseup = false

    # Create a new annotation
    if @annotation? and typeof @options.onCreate == 'function'
      @options.onCreate(@annotation)


# Public: Creates an element for editing annotations.
class Editor extends Widget

  # Classes to toggle state.
  classes:
    hide: 'annotator-hide'
    focus: 'annotator-focus'

  events:
    "form submit": "_onFormSubmit"
    ".annotator-save click": "_onSaveClick"
    ".annotator-cancel click": "_onCancelClick"
    ".annotator-cancel mouseover": "_onCancelMouseover"
    "textarea keydown": "_onTextareaKeydown"

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

    this.render()

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
  # window events are bound only when needed and throttled to only update
  # the positions at most 60 times a second.
  #
  # Returns nothing.
  _setupDraggables: ->
    @element.find('.annotator-resize').remove()

    # Find the first/last item element depending on orientation
    if @element.hasClass(@classes.invert.y)
      cornerItem = @element.find('.annotator-item:last')
    else
      cornerItem = @element.find('.annotator-item:first')

    if cornerItem
      $('<span class="annotator-resize"></span>').appendTo(cornerItem)

    mousedown = null
    classes   = @classes
    textarea  = null
    resize    = @element.find('.annotator-resize')
    controls  = @element.find('.annotator-controls')
    throttle  = false

    onMousedown = (event) ->
      if event.target == this
        mousedown = {
          element: this
          top: event.pageY
          left: event.pageX
        }

        # Find the first text area if there is one.
        textarea = @element.find('textarea:first')

        $(window).bind({
          'mouseup.annotator-editor-resize': onMouseup
          'mousemove.annotator-editor-resize': onMousemove
        })
        event.preventDefault()

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
          height = textarea.height()
          width  = textarea.width()

          directionX = if @element.hasClass(classes.invert.x) then -1 else  1
          directionY = if @element.hasClass(classes.invert.y) then  1 else -1

          textarea.height height + (diff.top  * directionY)
          textarea.width  width  + (diff.left * directionX)

          # Only update the mousedown object if the dimensions
          # have changed, otherwise they have reached their minimum
          # values.
          mousedown.top  = event.pageY unless textarea.height() == height
          mousedown.left = event.pageX unless textarea.width()  == width

        else if mousedown.element == controls[0]
          @element.css({
            top: parseInt(@element.css('top'), 10) + diff.top
            left: parseInt(@element.css('left'), 10) + diff.left
          })

          mousedown.top  = event.pageY
          mousedown.left = event.pageX

        throttle = true
        setTimeout((-> throttle = false), 1000 / 60)

    resize.bind   'mousedown', onMousedown
    controls.bind 'mousedown', onMousedown


# Highlighter provides a simple way to draw highlighted <span> tags over
# annotated ranges within a document.
class Highlighter
  options:
    # The CSS class to apply to drawn highlights
    highlightClass: 'annotator-hl'
    # Number of annotations to draw at once
    chunkSize: 10
    # Time (in ms) to pause between drawing chunks of annotations
    chunkDelay: 10

  # Public: Create a new instance of the Highlighter
  #
  # element - The root Element on which to dereference annotation ranges and
  #           draw highlights.
  # options - An options Object containing configuration options for the plugin.
  #           See `Highlights.options` for available options.
  #
  # Returns a new plugin instance.
  constructor: (@element, options) ->
    @options = $.extend(true, {}, @options, options)


  destroy: ->
    $(@element).find(".#{@options.highlightClass}").each (i, el) ->
      $(el).contents().insertBefore(el)
      $(el).remove()

  # Public: Draw highlights for all the given annotations
  #
  # annotations - An Array of annotation Objects for which to draw highlights.
  #
  # Returns nothing.
  drawAll: (annotations) =>
    return new Promise((resolve, reject) =>
      highlights = []

      loader = (annList = []) =>
        now = annList.splice(0, @options.chunkSize)

        for a in now
          highlights = highlights.concat(this.draw(a))

        # If there are more to do, do them after a delay
        if annList.length > 0
          setTimeout((-> loader(annList)), @options.chunkDelay)
        else
          resolve(highlights)

      clone = annotations.slice()
      loader(clone)
    )

  # Public: Draw highlights for the annotation.
  #
  # annotation - An annotation Object for which to draw highlights.
  #
  # Returns an Array of drawn highlight elements.
  draw: (annotation) =>
    normedRanges = []
    for r in annotation.ranges
      try
        normedRanges.push(Range.sniff(r).normalize(@element))
      catch e
        if e not instanceof Range.RangeError
          # Oh Javascript, why you so crap? This will lose the traceback.
          throw e
        # Otherwise, we simply swallow the error. Callers are responsible for
        # only trying to draw valid annotations.

    annotation._local ?= {}
    annotation._local.highlights ?= []

    for normed in normedRanges
      $.merge(
        annotation._local.highlights,
        highlightRange(normed, @options.highlightClass)
      )

    # Save the annotation data on each highlighter element.
    $(annotation._local.highlights).data('annotation', annotation)
    # Add a data attribute for annotation id if the annotation has one
    if annotation.id?
      $(annotation._local.highlights).attr('data-annotation-id', annotation.id)

    return annotation._local.highlights

  # Public: Remove the drawn highlights for the given annotation.
  #
  # annotation - An annotation Object for which to purge highlights.
  #
  # Returns nothing.
  undraw: (annotation) ->
    if annotation._local?.highlights?
      for h in annotation._local.highlights when h.parentNode?
        $(h).replaceWith(h.childNodes)
      delete annotation._local.highlights

  # Public: Redraw the highlights for the given annotation.
  #
  # annotation - An annotation Object for which to redraw highlights.
  #
  # Returns nothing.
  redraw: (annotation) =>
    this.undraw(annotation)
    this.draw(annotation)


# TextSelector monitors a document (or a specific element) for text selections
# and can notify another object of a selection event
class TextSelector

  constructor: (element, options) ->
    @element = element
    @options = options

    if @element.ownerDocument?
      @document = @element.ownerDocument
      $(@document.body)
      .on("mouseup.#{TEXTSELECTOR_NS}", this._checkForEndSelection)
    else
      console.warn("You created an instance of the TextSelector on an element
                    that doesn't have an ownerDocument. This won't work! Please
                    ensure the element is added to the DOM before the plugin is
                    configured:", @element)

  destroy: ->
    $(@document.body).off(".#{TEXTSELECTOR_NS}")

  # Public: capture the current selection from the document, excluding any nodes
  # that fall outside of the adder's `element`.
  #
  # Returns an Array of NormalizedRange instances.
  captureDocumentSelection: ->
    selection = Util.getGlobal().getSelection()

    ranges = []
    rangesToIgnore = []
    unless selection.isCollapsed
      ranges = for i in [0...selection.rangeCount]
        r = selection.getRangeAt(i)
        browserRange = new Range.BrowserRange(r)
        normedRange = browserRange.normalize().limit(@element)

        # If the new range falls fully outside our @element, we should add it
        # back to the document but not return it from this method.
        rangesToIgnore.push(r) if normedRange is null

        normedRange

      # BrowserRange#normalize() modifies the DOM structure and deselects the
      # underlying text as a result. So here we remove the selected ranges and
      # reapply the new ones.
      selection.removeAllRanges()

    for r in rangesToIgnore
      selection.addRange(r)

    # Remove any ranges that fell outside @element.
    ranges = $.grep(ranges, (range) ->
      # Add the normed range back to the selection if it exists.
      if range
        drange = @document.createRange()
        drange.setStartBefore(range.start)
        drange.setEndAfter(range.end)
        selection.addRange(drange)
      range
    )

    return ranges

  # Event callback: called when the mouse button is released. Checks to see if a
  # selection has been made and if so displays the adder.
  #
  # event - A mouseup Event object.
  #
  # Returns nothing.
  _checkForEndSelection: (event) =>
    _nullSelection = =>
      if typeof @options.onSelection == 'function'
        @options.onSelection([], event)

    # Get the currently selected ranges.
    selectedRanges = this.captureDocumentSelection()

    if selectedRanges.length == 0
      _nullSelection()
      return

    # Don't show the adder if the selection was of a part of Annotator itself.
    for range in selectedRanges
      container = range.commonAncestor
      if $(container).hasClass('annotator-hl')
        container = $(container).parents('[class!=annotator-hl]')[0]
      if this._isAnnotator(container)
        _nullSelection()
        return

    if typeof @options.onSelection == 'function'
      @options.onSelection(selectedRanges, event)


  # Determines if the provided element is part of Annotator. Useful for ignoring
  # mouse actions on the annotator elements.
  #
  # element - An Element or TextNode to check.
  #
  # Returns true if the element is a child of an annotator element.
  _isAnnotator: (element) ->
    !!$(element)
      .parents()
      .addBack()
      .filter('[class^=annotator-]')
      .length


# Public: Creates an element for viewing annotations.
class Viewer extends Widget

  # Classes for toggling annotator state.
  classes:
    showControls: 'annotator-visible'

  events:
    ".annotator-edit click": "_onEditClick"
    ".annotator-delete click": "_onDeleteClick"
    "mouseenter": "_onMouseenter"
    "mouseleave": "_onMouseleave"

  # HTML templates for @widget and @item properties.
  template:
    """
    <div class="annotator-outer annotator-viewer annotator-hide">
      <ul class="annotator-widget annotator-listing"></ul>
    </div>
    """

  itemTemplate:
    """
    <li class="annotator-annotation annotator-item">
      <span class="annotator-controls">
        <a href="#"
           title="View as webpage"
           class="annotator-link">View as webpage</a>
        <button type="button"
                title="Edit"
                class="annotator-edit">Edit</button>
        <button type="button"
                title="Delete"
                class="annotator-delete">Delete</button>
      </span>
    </li>
    """

  # Configuration options
  options:
    defaultFields: true # Add the default field(s) to the viewer.
    inactivityDelay: 500 # Time, in milliseconds, before the viewer is hidden
                         # when a user mouses off the viewer.
    activityDelay: 100 # Time, in milliseconds, before the viewer is updated
                       # when a user mouses over another annotation.
    showEditButton: false # Show the viewer's "edit" button. If shown, the
                          # button will fire an annotation "update" event, to
                          # which an appropriate editor instance can respond and
                          # display an editor.
    showDeleteButton: false # Show the viewer's "delete" button. If shown, the
                            # button will fire an annotation "delete" event.
    autoViewHighlights: null # If set to a DOM Element, will set up the viewer
                             # to automatically display when the user hovers
                             # over Annotator highlights within that element.
    onEdit: null # Callback, called when the user clicks the edit button for an
                 # annotation.
    onDelete: null # Callback, called when the user clicks the delete button for
                   # an annotation.

  # Public: Creates an instance of the Viewer object.
  #
  # options - An Object containing options.
  #
  # Examples
  #
  #   # Creates a new viewer, adds a custom field and displays an annotation.
  #   viewer = new Viewer()
  #   viewer.addField({
  #     load: someLoadCallback
  #   })
  #   viewer.load(annotation)
  #
  # Returns a new Viewer instance.
  constructor: (options) ->
    super

    @fields = []
    @annotations = []
    @hideTimer = null
    @hideTimerDfd = null
    @hideTimerActivity = null
    @mouseDown = false

    if @options.defaultFields
      this.addField({
        load: (field, annotation) =>
          if annotation.text
            $(field).html(Util.escape(annotation.text))
          else
            $(field).html("<i>#{_t 'No Comment'}</i>")
      })

    if @options.autoViewHighlights?
      @document = @options.autoViewHighlights.ownerDocument

      $(@options.autoViewHighlights)
      .on("mouseover.#{VIEWER_NS}", '.annotator-hl', this._onHighlightMouseover)
      .on("mouseleave.#{VIEWER_NS}", '.annotator-hl', this._onHighlightMouseleave)

      $(@document.body)
      .on("mousedown.#{VIEWER_NS}", (e) => @mouseDown = true if e.which == 1)
      .on("mouseup.#{VIEWER_NS}", (e) => @mouseDown = false if e.which == 1)

    this.render()

  destroy: ->
    super
    if @options.autoViewHighlights?
      $(@options.autoViewHighlights).off(".#{VIEWER_NS}")
      $(@document.body).off(".#{VIEWER_NS}")

  # Public: Show the viewer.
  #
  # position - An Object specifying the position in which to show the editor
  #            (optional).
  #
  # Examples
  #
  #   viewer.show()
  #   viewer.hide()
  #   viewer.show({top: '100px', left: '80px'})
  #
  # Returns nothing.
  show: (position = null) ->
    if position?
      @element.css({
        top: position.top,
        left: position.left
      })

    controls = @element
      .find('.annotator-controls')
      .addClass(@classes.showControls)
    setTimeout((=> controls.removeClass(@classes.showControls)), 500)

    super

  # Public: Load annotations into the viewer and show it.
  #
  # annotation - An Array of annotations.
  #
  # Examples
  #
  #   viewer.load([annotation1, annotation2, annotation3])
  #
  # Returns nothing.
  load: (annotations, position = null) =>
    @annotations = annotations || []

    list = @element.find('ul:first').empty()
    for annotation in @annotations
      item = $(@itemTemplate)
      .clone()
      .appendTo(list)
      .data('annotation', annotation)

      controls = item.find('.annotator-controls')

      link = controls.find('.annotator-link')
      edit = controls.find('.annotator-edit')
      del  = controls.find('.annotator-delete')

      links = new LinkParser(annotation.links or [])
        .get('alternate', {'type': 'text/html'})
      if links.length is 0 or not links[0].href?
        link.remove()
      else
        link.attr('href', links[0].href)

      controller = {}
      if @options.showEditButton
        controller.showEdit = -> edit.removeAttr('disabled')
        controller.hideEdit = -> edit.attr('disabled', 'disabled')
      else
        edit.remove()
      if @options.showDeleteButton
        controller.showDelete = -> del.removeAttr('disabled')
        controller.hideDelete = -> del.attr('disabled', 'disabled')
      else
        del.remove()

      for field in @fields
        element = $(field.element).clone().appendTo(item)[0]
        field.load(element, annotation, controller)

    this.show(position)

  # Public: Adds an addional field to an annotation view. A callback can be
  # provided to update the view on load.
  #
  # options - An options Object. Options are as follows:
  #           load - Callback Function called when the view is loaded with an
  #                  annotation. Recieves a newly created clone of an item and
  #                  the annotation to be displayed (it will be called once
  #                  for each annotation being loaded).
  #
  # Examples
  #
  #   # Display a user name.
  #   viewer.addField({
  #     # This is called when the viewer is loaded.
  #     load: (field, annotation) ->
  #       field = $(field)
  #
  #       if annotation.user
  #         field.text(annotation.user) # Display the user
  #       else
  #         field.remove()              # Do not display the field.
  #   })
  #
  # Returns itself.
  addField: (options) ->
    field = $.extend({
      load: ->
    }, options)

    field.element = $('<div />')[0]
    @fields.push(field)
    this

  # Event callback: called when the edit button is clicked.
  #
  # event - An Event object.
  #
  # Returns nothing.
  _onEditClick: (event) ->
    item = $(event.target).parents('.annotator-annotation').data('annotation')
    this.hide()
    if typeof @options.onEdit == 'function'
      @options.onEdit(item)

  # Event callback: called when the delete button is clicked.
  #
  # event - An Event object.
  #
  # Returns nothing.
  _onDeleteClick: (event) ->
    item = $(event.target).parents('.annotator-annotation').data('annotation')
    this.hide()
    if typeof @options.onDelete == 'function'
      @options.onDelete(item)

  # Event callback: called when a user's cursor enters the viewer element.
  #
  # event - An Event object.
  #
  # Returns nothing.
  _onMouseenter: (event) ->
    this._clearHideTimer()

  # Event callback: called when a user's cursor leaves the viewer element.
  #
  # event - An Event object.
  #
  # Returns nothing.
  _onMouseleave: (event) ->
    this._startHideTimer()

  # Event callback: called when a user triggers `mouseover` on a highlight
  # element.
  #
  # event - An Event object.
  #
  # Returns nothing.
  _onHighlightMouseover: (event) =>
    # If the mouse button is currently depressed, we're probably trying to make
    # a selection, so we shouldn't show the viewer.
    if @mouseDown
      return

    this._startHideTimer(true)
    .done =>
      annotations = $(event.target)
        .parents('.annotator-hl')
        .addBack()
        .map((idx, elem) -> $(elem).data("annotation"))
        .toArray()

      # Now show the viewer with the wanted annotations
      offset = @element.parent().offset()
      position = {
        top: event.pageY - offset.top,
        left: event.pageX - offset.left,
      }
      this.load(annotations, position)

  # Event callback: called when a user's cursor leaves a highlight element.
  #
  # event - An Event object.
  #
  # Returns nothing.
  _onHighlightMouseleave: (event) =>
    this._startHideTimer()

  # Starts the hide timer. This returns a promise that is resolved when the
  # viewer has been hidden. If the viewer is already hidden, the promise will be
  # resolved instantly.
  #
  # activity - A boolean indicating whether the need to hide is due to a user
  #            actively indicating a desire to view another annotation (as
  #            opposed to merely mousing off the current one). Default: false
  #
  # Returns a Promise.
  _startHideTimer: (activity = false) =>
    # If timer has already been set, use that one.
    if @hideTimer
      if activity == false or @hideTimerActivity == activity
        return @hideTimerDfd
      else
        # The pending timeout is an inactivity timeout, so likely to be too
        # slow. Clear the pending timeout and start a new (shorter) one!
        this._clearHideTimer()

    if activity
      timeout = @options.activityDelay
    else
      timeout = @options.inactivityDelay

    @hideTimerDfd = $.Deferred()

    if not this.isShown()
      @hideTimer = null
      @hideTimerDfd.resolve()
      @hideTimerActivity = null
    else
      @hideTimer = setTimeout((=>
        this.hide()
        @hideTimerDfd.resolve()
        @hideTimer = null
      ), timeout)
      @hideTimerActivity = !!activity

    return @hideTimerDfd.promise()

  # Clears the hide timer. Also rejects any promise returned by a previous call
  # to _startHideTimer.
  #
  # Returns nothing.
  _clearHideTimer: =>
    clearTimeout(@hideTimer)
    @hideTimer = null
    @hideTimerDfd.reject()
    @hideTimerActivity = null


# Private: simple parser for hypermedia link structure
#
# Examples:
#
#   links = [
#     {
#       rel: 'alternate',
#       href: 'http://example.com/pages/14.json',
#       type: 'application/json'
#     },
#     {
#       rel: 'prev':
#       href: 'http://example.com/pages/13'
#     }
#   ]
#
#   lp = LinkParser(links)
#   lp.get('alternate') # => [ { rel: 'alternate', href: 'http://...', ... } ]
#   lp.get('alternate', {type: 'text/html'}) # => []
#
class LinkParser
  constructor: (@data) ->

  get: (rel, cond = {}) ->
    cond = $.extend({}, cond, {rel: rel})
    keys = (k for own k, v of cond)
    for d in @data
      match = keys.reduce ((m, k) -> m and (d[k] is cond[k])), true
      if match
        d
      else
        continue


exports.Adder = Adder
exports.Editor = Editor
exports.Highlighter = Highlighter
exports.TextSelector = TextSelector
exports.Viewer = Viewer
exports.Widget = Widget
