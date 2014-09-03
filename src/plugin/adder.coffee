Widget = require('../widget')
Util = require('../util')
$ = Util.$
_t = Util.TranslationString

ADDER_NS = 'annotator-adder'
ADDER_HTML =
  """
  <div class="annotator-adder annotator-hide">
    <button type="button">#{_t('Annotate')}</button>
  </div>
  """

# Public: Provide an adder button to use for creating annotations
class Adder extends Widget
  events:
    "button click": "_onClick"
    "button mousedown": "_onMousedown"

  template: ADDER_HTML

  constructor: (options) ->
    super
    @ignoreMouseup = false

  configure: ({@core}) ->
    # The Adder is now an optional plugin, and
    # plugins should not refer to it using
    # annotator.adder! Please use
    # annotator.plugins.Adder instead.
    @core.adder = this

  pluginInit: ->
    @document = @element[0].ownerDocument
    $(@document.body).on("mouseup.#{ADDER_NS}", this._onMouseup)
    this.listenTo(@core, 'selection', @onSelection)
    this.render()

  destroy: ->
    super
    this.stopListening(@core, 'selection', @onSelection)
    $(@document.body).off(".#{ADDER_NS}")

  onSelection: (annotationSkeleton) =>
    if annotationSkeleton # Did we get any data?
      # We have received a prepared annotation skeleton.
      @selectedSkeleton = annotationSkeleton
      @show()
    else
      # No data means that this was a failed selection.
      # Hide the adder.
      @hide()

  # Public: Show the adder.
  #
  # Returns nothing.
  show: =>
    if @core.interactionPoint?
      @element.css({
        top: @core.interactionPoint.top,
        left: @core.interactionPoint.left
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
    @core.annotations.create(@selectedSkeleton)


# This is a core plugin (registered by default with Annotator), so we don't
# register here. If you're writing a plugin of your own, please refer to a
# non-core plugin (such as Document or Store) to see how to register your plugin
# with Annotator.

module.exports = Adder
