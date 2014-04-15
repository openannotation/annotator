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
    readOnly: false # Start the viewer in read-only mode. No controls will be
                    # shown.
    showEditButton: false # Show the viewer's "edit" button. If shown, the
                          # button will fire an annotation "update" event, to
                          # which an appropriate editor instance can respond and
                          # display an editor.
    showDeleteButton: false # Show the viewer's "delete" button. If shown, the
                            # button will fire an annotation "delete" event.

  # Public: Creates an instance of the Viewer object.
  #
  # options - An Object literal containing options.
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
  constructor: (@element, options) ->
    super
    @options = $.extend(true, {}, @options, options)

    @fields = []
    @annotations = []
    @hideTimer = null
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
            @core.publish('annotationViewerTextField', [field, annotation])
      })

  configure: ({@core}) ->

  pluginInit: ->
    if @element.ownerDocument?
      @document = @element.ownerDocument
      @item = $(@html.item)
      @widget = $(@html.viewer).appendTo(@document.body)
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

  # Public: Displays the Viewer and first the "show" event. Can be used as an
  # event callback and will call Event#preventDefault() on the supplied event.
  #
  # event - Event object provided if method is called by event
  #         listener (default:undefined)
  #
  # Examples
  #
  #   # Displays the editor.
  #   viewer.show()
  #
  #   # Displays the viewer on click (prevents default action).
  #   $('a.show-viewer').bind('click', viewer.show)
  #
  # Returns itself.
  show: (event) =>
    Util.preventEventDefault event

    controls = @widget
      .find('.annotator-controls')
      .addClass(@classes.showControls)
    setTimeout((=> controls.removeClass(@classes.showControls)), 500)

    @widget.removeClass(@classes.hide)
    this.checkOrientation()

  # Public: Checks to see if the Viewer is currently displayed.
  #
  # Examples
  #
  #   viewer.show()
  #   viewer.isShown() # => Returns true
  #
  #   viewer.hide()
  #   viewer.isShown() # => Returns false
  #
  # Returns true if the Viewer is visible.
  isShown: ->
    not @widget.hasClass(@classes.hide)

  # Public: Hides the Editor and fires the "hide" event. Can be used as an event
  # callback and will call Event#preventDefault() on the supplied event.
  #
  # event - Event object provided if method is called by event
  #         listener (default:undefined)
  #
  # Examples
  #
  #   # Hides the editor.
  #   viewer.hide()
  #
  #   # Hide the viewer on click (prevents default action).
  #   $('a.hide-viewer').bind('click', viewer.hide)
  #
  # Returns itself.
  hide: (event) =>
    Util.preventEventDefault event
    @widget.addClass(@classes.hide)

  # Public: Loads annotations into the viewer and shows it. Fires the "load"
  # event once the viewer is loaded passing the annotations into the callback.
  #
  # annotation - An Array of annotation elements.
  # position - An Object describing where to display the viewer (with properties
  #            `top` and `left`)
  #
  # Examples
  #
  #   viewer.load([annotation1, annotation2, annotation3])
  #
  # Returns itslef.
  load: (annotations, position) =>
    if position?
      @widget.css({top: position.top, left: position.left})

    @annotations = annotations || []

    list = @widget.find('ul:first').empty()
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

      if @options.readOnly
        edit.remove()
        del.remove()
      else
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
  _onEditClick: (event) ->
    item = $(event.target).parents('.annotator-annotation').data('annotation')
    console.log("Would edit", item)

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

    this._startHideTimer()
    .done =>
      # coffeelint: disable=missing_fat_arrows
      annotations = $(event.target)
        .parents('.annotator-hl')
        .addBack()
        .map(-> return $(this).data("annotation"))
        .toArray()
      # coffeelint: enable=missing_fat_arrows

      # Now show the viewer with the wanted annotations
      offset = @widget.parent().offset()
      this.load(
        annotations,
        {
          top: event.pageY - offset.top,
          left: event.pageX - offset.left,
        }
      )

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
  # Returns a Promise.
  _startHideTimer: =>
    # If timer has already been set, use that one.
    if @hideTimer
      return @hideTimerDfd

    @hideTimerDfd = $.Deferred()

    if not this.isShown()
      @hideTimerDfd.resolve()
    else
      @hideTimer = setTimeout((=>
        this.hide()
        @hideTimerDfd.resolve()
        @hideTimer = null
      ), 250)

    return @hideTimerDfd

  # Clears the hide timer. Also rejects any promise returned by a previous call
  # to _startHideTimer.
  #
  # Returns nothing.
  _clearHideTimer: =>
    clearTimeout(@hideTimer)
    @hideTimerDfd.reject()
    @hideTimer = null

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
