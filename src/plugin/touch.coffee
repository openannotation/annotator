# Plugin for the Annotator to improve the experience on touch devices. In
# general it wraps the Viewer and Editor elements and increases the hit area
# of buttons. Getting the selected text is handled by polling the
# getSelection() method on the window object. This is supported by most
# devices that implement native text selection tools such as Safari on iOS.
#
# Examples
#
#   jQuery("#annotator").annotator().annotator('addPlugin', 'Touch');
#
# Returns a new instance of the Touch plugin.
class Annotator.Plugin.Touch extends Annotator.Plugin
  # Export some useful globals into the class scope.
  _t = Annotator._t
  jQuery = Annotator.$

  # States for the "data-state" property on the annotator-touch-controls
  # element. ON means the annotattor is enabled. OFF is disabled.
  @states: ON: "on", OFF: "off"

  # Template for the Touch annotator controls.
  template: """
  <div class="annotator-touch-widget annotator-touch-controls annotator-touch-hide">
    <div class="annotator-touch-widget-inner">
      <a class="annotator-button annotator-add annotator-focus">""" + _t("Annotate") + """</a>
      <a class="annotator-button annotator-touch-toggle" data-state="off">""" + _t("Start Annotating") + """</a>
    </div>
  </div>
  """

  # Classes to be used to control the state.
  classes:
    hide: "annotator-touch-hide"

  # Instance options can be used to configure the annotator at runtime.
  options:
    # Forces the touch controls to be loaded into the page. This is useful
    # for testing or if the annotator will always be used in a touch device
    # (say when bundled into an application).
    force: false

    # For devices that do not have support for accessing the browsers selected
    # text this plugin supports the inclusion of the Highlighter library that
    # goes someway to implementing these features in JavaScript.
    useHighlighter: false

  # Initialises the plugin and sets up instance variables.
  #
  # element - The root Annotator element.
  # options - An object of options for the plugin see @options.
  #           force: Should force plugin on desktop (default: false).
  #           useHighlighter: Should use Highlighter (default: false).
  #
  # Returns nothing.
  constructor: (element, options) ->
    super

    @utils = Annotator.Plugin.Touch.utils
    @selection = null
    @document = jQuery(document)

  # Internal: Updates the plugin after the Annotator has been loaded and
  # attached to the plugin instance. This should be used to register
  # Editor and Viewer fields.
  #
  # Returns nothing.
  pluginInit: ->
    return unless Annotator.supported() and (@options.force or Touch.isTouchDevice())

    @_setupControls()

    # Only need this for some Android browsers at the moment. The simulator
    # fails to select the highlights but the Galaxy Tab running 3.2 works
    # okay. There is no way to feature detect whether or not the Highlighter
    # should be used so it must be enabled with @options.useHighlighter.
    if @options.useHighlighter
      @showControls()
      @highlighter = new Highlighter
        root:   @element[0]
        prefix: "annotator-selection"
        enable: false
        highlightStyles: true

    # Bind tap event listeners to the highlight elements. We delegate to the
    # document rather than the container to prevent WebKit requiring a
    # double tap to bring up the text selection tool.
    @document.delegate(".annotator-hl", "tap", preventDefault: false, @_onHighlightTap)

    @subscribe("selection", @_onSelection)

    @_unbindAnnotatorEvents()
    @_setupAnnotatorEvents()
    @_watchForSelection()

  # Internal: Method for tearing down a plugin, removing all event listeners
  # and timers etc that it has created. This should be called when the plugin
  # is removed from the DOM.
  #
  # Examples
  #
  #   annotator.element.remove()
  #   touch.pluginDestroy()
  #
  # Returns nothing.
  pluginDestroy: ->
    @controls.remove() if @controls
    @highlighter.disable() if @highlighter
    @annotator.editor.unsubscribe "hide", @_watchForSelection if @annotator

  # Public: Enables the highlighter and the annotator button. This is only
  # used when the highlighter is used to switch between JavaScript and
  # Native text selection.
  #
  # Examples
  #
  #   touch.startAnnotating()
  #
  # Returns itself.
  startAnnotating: ->
    @highlighter.enable() if @highlighter
    @toggle.attr("data-state", Touch.states.ON)
    @toggle.html("Stop Annotating")
    this

  # Public: Disables the highlighter and the annotator button.
  #
  # Examples
  #
  #   touch.startAnnotating()
  #
  # Returns itself.
  stopAnnotating: ->
    @highlighter.disable() if @highlighter
    @toggle.attr("data-state", Touch.states.OFF)
    @toggle.html("Start Annotating")
    this

  # Public: Checks to see if the annotator is currently enabled.
  #
  # Examples
  #
  #   if touch.isAnnotating() then doSomething()
  #
  # Returns true if the annotator is enabled.
  isAnnotating: ->
    usingHighlighter = @options.useHighlighter
    not usingHighlighter or @toggle.attr("data-state") is Touch.states.ON

  # Public: Shows the Editor and hides the Touch controls.
  #
  # annotation - An annotation object to load into the Editor.
  #
  # Returns itself.
  showEditor: (annotation) ->
    @annotator.showEditor(annotation, {})
    @hideControls()
    this

  # Public: Displays the touch controls.
  #
  # Returns itself.
  showControls: ->
    @controls.removeClass(@classes.hide)
    this

  # Public: Hides the touch controls.
  #
  # Returns itself.
  hideControls: ->
    @controls.addClass(@classes.hide) unless @options.useHighlighter
    this

  # Sets up the touch controls and binds events, also removes the default
  # adder. Should only be called in the @pluginInit() method.
  #
  # Returns nothing.
  _setupControls: ->
    @annotator.adder.remove()

    @controls = jQuery(@template).appendTo("body")

    @adder = @controls.find(".annotator-add")
    @adder.bind("tap", (onTapDown: (event) -> event.stopPropagation()), @_onAdderTap)

    @toggle = @controls.find(".annotator-touch-toggle")
    @toggle.bind("tap": @_onToggleTap)
    @toggle.hide() unless @options.useHighlighter

  # Setup method that creates the @editor and @viewer properties. Should
  # only be called once by the @pluginInit() method.
  #
  # Returns nothing.
  _setupAnnotatorEvents: ->
    # Wrap the interface elements with touch controls.
    @editor = new Touch.Editor(@annotator.editor)
    @viewer = new Touch.Viewer(@annotator.viewer)

    # Ensure the annotate buttom is hidden when the interface is visible.
    @annotator.editor.on "show", =>
      @_clearWatchForSelection()
      @annotator.onAdderMousedown()
      @highlighter.disable() if @highlighter

    @annotator.viewer.on "show", =>
      @highlighter.disable() if @highlighter

    @annotator.editor.on "hide", =>
      @utils.nextTick =>
        @highlighter.enable().deselect() if @highlighter
        @_watchForSelection()

    @annotator.viewer.on "hide", =>
      @utils.nextTick =>
        @highlighter.enable().deselect() if @highlighter

  # Removes the default mouse event bindings created by the Annotator.
  #
  # Returns nothing.
  _unbindAnnotatorEvents: ->
    # Remove mouse events from document.
    @document.unbind
      "mouseup":   @annotator.checkForEndSelection
      "mousedown": @annotator.checkForStartSelection

    # Unbind mouse events from the root element to prevent the iPad giving
    # it a grey selected outline when interacted with.
    # NOTE: This currently unbinds _all_ events event those set up by
    # other plugins.
    @element.unbind("click mousedown mouseover mouseout")

  # Begins a timer stored in @timer that polls the page to see if a selection
  # has been made. Clear the timer with @_clearWatchForSelection().
  #
  # Examples
  #
  #   jQuery(window).focus(touch._watchForSelection)
  #
  # Returns nothing.
  _watchForSelection: =>
    return if @timer

    # There are occsions where Android will clear the text selection before
    # firing touch events. So we slow down the polling to ensure that touch
    # events get time to read the current selection.
    interval = if Touch.isAndroid() then 300 else 1000 / 60
    start = new Date().getTime()

    # Use request animation frame despite the fact it runs to regularly to
    # take advantage of the fact it stops running when the window is idle.
    # If this becomes a performance bottleneck consider switching to a
    # longer setTimeout() and managing the start/stop manually.
    step = =>
      progress = (new Date().getTime()) - start
      if progress > interval
        start = new Date().getTime()
        @_checkSelection()
      @timer = @utils.requestAnimationFrame.call(window, step)
    step()

  # Clears the @timer that polls for selections in the document. Call this
  # when the user is idle or selection is not required.
  #
  # Returns nothing.
  _clearWatchForSelection: ->
    @utils.cancelAnimationFrame.call(window, @timer)
    @timer = null

  # Checks the current text selection and if changed fires the "selection"
  # event with the currently selected Range object and the plugin instance
  # passed in as an argument.
  #
  # Returns nothing.
  _checkSelection: ->
    selection = window.getSelection()
    previous  = @selectionString
    string    = jQuery.trim(selection + "")

    if selection.rangeCount and string isnt @selectionString
      @range = selection.getRangeAt(0)
      @selectionString = string

    if selection.rangeCount is 0 or (@range and @range.collapsed)
      @range = null
      @selectionString = ""

    @publish("selection", [@range, this]) unless @selectionString is previous

  # Determines whether or not to show the annotator button depending on the
  # current text selection.
  #
  # Examples
  #
  #   plugin.subscribe("selection", @_onSelection)
  #
  # Returns nothing.
  _onSelection: =>
    if @isAnnotating() and @range and @_isValidSelection(@range)
      @adder.removeAttr("disabled")
      @showControls()
    else
      @adder.attr("disabled", "")
      @hideControls()

  # Checks to see if any part of the provided Range object falls within the
  # annotator element.
  #
  # range - A native Range instance.
  #
  # Examples
  #
  #   range = window.getSelectedText().rangeAt(0)
  #   if touch._isValidSelection(range) then annotateText()
  #
  # Returns true if the annotator element contains selected nodes.
  _isValidSelection: (range) ->
    # jQuery.contains() doesn't appear to work with range nodes.
    inElement = (node) -> jQuery(node).parents('.annotator-wrapper').length

    isStartOffsetValid = range.startOffset < range.startContainer.length
    isValidStart = isStartOffsetValid and inElement(range.startContainer)
    isValidEnd = range.endOffset > 0 and inElement(range.endContainer)

    isValidStart or isValidEnd

  # Event callback for the Annotator Start/Stop button.
  #
  # event - A jQuery.Event touch event object.
  #
  # Returns nohting.
  _onToggleTap: (event) =>
    event.preventDefault()
    if @isAnnotating() then @stopAnnotating() else @startAnnotating()

  # Event callback for the Annotate adder button. Checks the current selection
  # and displays the editor.
  #
  # event - A jQuery.Event touch event object.
  #
  # Returns nothing.
  _onAdderTap: (event) =>
    event.preventDefault()
    if @range
      browserRange = new Annotator.Range.BrowserRange(@range)
      range = browserRange.normalize().limit(@element[0])

      if range and not @annotator.isAnnotator(range.commonAncestor)
        # Here we manually apply our captured range to the annotation object
        # because we cannot rely on @selectedRanges on touch browsers.
        onAnnotationCreated = (annotation) =>
          @annotator.unsubscribe('beforeAnnotationCreated', onAnnotationCreated)
          annotation.quote= range.toString()
          annotation.ranges = [range]

        @annotator.subscribe('beforeAnnotationCreated', onAnnotationCreated)

        # Trigger the main adder handler which handles displaying the editor
        # and triggering the correct events for persistance.
        @annotator.onAdderClick(event)

  # Event callback for tap events on highlights and displays the Viewer.
  # Allows events on anchor elements and those with the
  # "data-annotator-clickable" attribute to pass through. Watches the
  # document for further taps in order to remove the viewer.
  #
  # event - A jQuery.Event touch event object.
  #
  # Returns nothing.
  _onHighlightTap: (event) =>
    # Check to see if clicked element should be ignored.
    clickable = jQuery(event.currentTarget).parents().filter ->
      jQuery(this).is('a, [data-annotator-clickable]')
    return if clickable.length

    if jQuery.contains(@element[0], event.currentTarget)
      original = event.originalEvent
      if original and original.touches
        event.pageX = original.touches[0].pageX
        event.pageY = original.touches[0].pageY

      @annotator.viewer.hide() if @annotator.viewer.isShown()
      @annotator.onHighlightMouseover(event)

      @document.unbind("tap", @_onDocumentTap)
      @document.bind("tap", preventDefault: false, @_onDocumentTap)

  # Event handler for document taps. This is used to hide the viewer when
  # the document it tapped.
  #
  # event - A jQuery.Event touch event object.
  #
  # Returns nothing.
  _onDocumentTap: (event) =>
    unless @annotator.isAnnotator(event.target)
      @annotator.viewer.hide()
    @document.unbind("tap", @_onDocumentTap) unless @annotator.viewer.isShown()

  # Public: Checks to see if the current device is capable of handling
  # touch events.
  #
  # Examples
  #
  #   if Touch.isTouchDevice()
  #     # Browser handles touch events.
  #   else
  #     # Browser does not handle touch events.
  #
  # Returns true if the device appears so support touch events.
  @isTouchDevice: ->
    ('ontouchstart' of window) or window.DocumentTouch and document instanceof DocumentTouch

  # Public: Horrible browser sniffing hack for detecting Android, this should
  # only be used to fix bugs in the browser where feature detection cannot
  # be used.
  #
  # Returns true if the browser's user agent contains the string "Android".
  @isAndroid: ->
    (/Android/i).test(window.navigator.userAgent)
