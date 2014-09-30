Widget = require('./widget').Widget
Util = require('../util')

$ = Util.$
_t = Util.TranslationString

NS = 'annotator-viewer'


# Public: Creates an element for viewing annotations.
class Viewer extends Widget

  # Classes for toggling annotator state.
  classes:
    showControls: 'annotator-visible'

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
    # Add the default field(s) to the viewer.
    defaultFields: true

    # Time, in milliseconds, before the viewer is hidden when a user mouses off
    # the viewer.
    inactivityDelay: 500

    # Time, in milliseconds, before the viewer is updated when a user mouses
    # over another annotation.
    activityDelay: 100

    # Show the viewer's "edit" button?
    showEditButton: false

    # Show the viewer's "delete" button?
    showDeleteButton: false

    # If set to a DOM Element, will set up the viewer to automatically display
    # when the user hovers over Annotator highlights within that element.
    autoViewHighlights: null

    # Callback, called when the user clicks the edit button for an annotation.
    onEdit: null

    # Callback, called when the user clicks the delete button for an annotation.
    onDelete: null

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
        load: (field, annotation) ->
          if annotation.text
            $(field).html(Util.escape(annotation.text))
          else
            $(field).html("<i>#{_t 'No Comment'}</i>")
      })

    if @options.autoViewHighlights?
      @document = @options.autoViewHighlights.ownerDocument

      $(@options.autoViewHighlights)
        .on("mouseover.#{NS}", '.annotator-hl', this._onHighlightMouseover)
        .on("mouseleave.#{NS}", '.annotator-hl', => this._startHideTimer())

      $(@document.body)
        .on("mousedown.#{NS}", (e) => @mouseDown = true if e.which == 1)
        .on("mouseup.#{NS}", (e) => @mouseDown = false if e.which == 1)

    @element
      .on("click.#{NS}", '.annotator-edit', (e) => this._onEditClick(e))
      .on("click.#{NS}", '.annotator-delete', (e) => this._onDeleteClick(e))
      .on("mouseenter.#{NS}", => this._clearHideTimer())
      .on("mouseleave.#{NS}", => this._startHideTimer())

    this.render()

  destroy: ->
    if @options.autoViewHighlights?
      $(@options.autoViewHighlights).off(".#{NS}")
      $(@document.body).off(".#{NS}")
    @element.off(".#{NS}")
    super

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


exports.Viewer = Viewer
