Util = require('../util')
Widget = require('../widget')
$ = Util.$
_t = Util.TranslationString

ns = 'annotator-viewer'

# Public: Creates an element for viewing annotations.
class Viewer extends Widget

  # Classes for toggling annotator state.
  classes:
    hide: 'annotator-hide'
    showControls: 'annotator-visible'

  # HTML templates for @widget and @item properties.
  html:
    viewer: """
      <div class="annotator-outer annotator-viewer annotator-hide">
        <ul class="annotator-widget annotator-listing"></ul>
      </div>
      """
    item: """
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

  # Public: Creates an instance of the Viewer object.
  #
  # element - An Element within which to attach events to show the viewer
  #           automatically when the user's mouse hovers over annotation
  #           highlights.
  # options - An Object containing options.
  #
  # Examples
  #
  #   # Creates a new viewer, adds a custom field and displays an annotation.
  #   viewer = new Viewer(elem)
  #   viewer.addField({
  #     load: someLoadCallback
  #   })
  #   viewer.load(annotation)
  #
  # Returns a new Viewer instance.
  constructor: (@element, options) ->
    super
    @options = $.extend(true, {}, @options, options)

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
          # FIXME: deprecate and remove this event
          if @core?
            @core.trigger('annotationViewerTextField', field, annotation)
      })

  configure: ({@core}) ->

  pluginInit: ->
    if @element.ownerDocument?
      @document = @element.ownerDocument
      @item = $(@html.item)
      @widget = $(@html.viewer).appendTo(@document.body).get(0)
      $(@widget)
      .on("click.#{ns}", '.annotator-edit', this._onEditClick)
      .on("click.#{ns}", '.annotator-delete', this._onDeleteClick)
      .on("mouseenter.#{ns}", this._onMouseenter)
      .on("mouseleave.#{ns}", this._onMouseleave)
      $(@element)
      .on("mouseover.#{ns}", '.annotator-hl', this._onHighlightMouseover)
      .on("mouseleave.#{ns}", '.annotator-hl', this._onHighlightMouseleave)
      $(@document.body)
      .on("mousedown.#{ns}", (e) => @mouseDown = true if e.which == 1)
      .on("mouseup.#{ns}", (e) => @mouseDown = false if e.which == 1)
    else
      console.warn("You created an instance of the Viewer on an element that
                    doesn't have an ownerDocument. This won't work! Please
                    ensure the element is added to the DOM before the plugin is
                    configured:", @element)

  destroy: ->
    $(@widget).off(".#{ns}")
    $(@element).off(".#{ns}")
    super

  # Public: Show the viewer.
  #
  # Returns nothing.
  show: ->
    if @core.interactionPoint?
      $(@widget).css({
        top: @core.interactionPoint.top,
        left: @core.interactionPoint.left
      })
    controls = $(@widget)
      .find('.annotator-controls')
      .addClass(@classes.showControls)
    setTimeout((=> controls.removeClass(@classes.showControls)), 500)

    $(@widget).removeClass(@classes.hide)
    this.checkOrientation()

  # Public: Hide the viewer.
  #
  # Returns nothing.
  hide: ->
    $(@widget).addClass(@classes.hide)

  # Public: Returns true if the viewer is currently displayed, false otherwise.
  #
  # Examples
  #
  #   viewer.show()
  #   viewer.isShown() # => true
  #
  #   viewer.hide()
  #   viewer.isShown() # => false
  #
  # Returns true if the viewer is visible.
  isShown: ->
    not $(@widget).hasClass(@classes.hide)

  # Public: Load annotations into the viewer and show it.
  #
  # annotation - An Array of annotations.
  #
  # Examples
  #
  #   viewer.load([annotation1, annotation2, annotation3])
  #
  # Returns nothing.
  load: (annotations) =>
    @annotations = annotations || []

    list = $(@widget).find('ul:first').empty()
    for annotation in @annotations
      item = $(@item).clone().appendTo(list).data('annotation', annotation)
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

    this.show()

  # Public: Adds an addional field to an annotation view. A callback can be
  # provided to update the view on load.
  #
  # options - An options Object. Options are as follows:
  #           load - Callback Function called when the view is loaded with an
  #                  annotation. Recieves a newly created clone of @item and
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
  _onEditClick: (event) =>
    item = $(event.target).parents('.annotator-annotation').data('annotation')
    this.hide()
    @core.annotations.update(item)

  # Event callback: called when the delete button is clicked.
  #
  # event - An Event object.
  #
  # Returns nothing.
  _onDeleteClick: (event) =>
    item = $(event.target).parents('.annotator-annotation').data('annotation')
    this.hide()
    @core.annotations.delete(item)

  # Event callback: called when a user's cursor enters the viewer element.
  #
  # event - An Event object.
  #
  # Returns nothing.
  _onMouseenter: (event) =>
    this._clearHideTimer()

  # Event callback: called when a user's cursor leaves the viewer element.
  #
  # event - An Event object.
  #
  # Returns nothing.
  _onMouseleave: (event) =>
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
      offset = $(@widget).parent().offset()
      @core.interactionPoint = {
        top: event.pageY - offset.top,
        left: event.pageX - offset.left,
      }
      this.load(annotations)

      # FIXME: deprecate this event
      @core.trigger('annotationViewerShown', this, annotations)

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


# This is a core plugin (registered by default with Annotator), so we don't
# register here. If you're writing a plugin of your own, please refer to a
# non-core plugin (such as Document or Store) to see how to register your plugin
# with Annotator.

module.exports = Viewer
