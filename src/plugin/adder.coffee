Range = require('../range')
Util = require('../util')
$ = Util.$
_t = Util.TranslationString

ADDER_NS = 'annotator-adder'
ADDER_HIDE_CLASS = 'annotator-hide'
ADDER_HTML = """
             <div class="annotator-adder #{ADDER_HIDE_CLASS}">
               <button type="button">#{_t('Annotate')}</button>
             </div>
             """

# Public: Provide an adder button to use for creating annotations
class Adder

  constructor: (element) ->
    @element = element

  configure: ({@core}) ->
      @core.ignoreMouseup = false
      @core.onSuccessfulSelection = @show
      @core.onFailedSelection = @hide

  pluginInit: ->
    if @element.ownerDocument?
      @document = @element.ownerDocument
      @adder = $(ADDER_HTML).appendTo(@document.body)[0]
      $(@adder)
      .on("click.#{ADDER_NS}", 'button', this._onClick)
      .on("mousedown.#{ADDER_NS}", 'button', this._onMousedown)

    else
      console.warn("You created an instance of the Adder on an element that
                    doesn't have an ownerDocument. This won't work! Please
                    ensure the element is added to the DOM before the plugin is
                    configured:", @element)

  destroy: ->
    $(@adder)
    .off(".#{ADDER_NS}")
    .remove()

  # Public: Show the adder.
  #
  # Returns nothing.
  show: =>
    if @core.interactionPoint?
      $(@adder).css({
        top: @core.interactionPoint.top,
        left: @core.interactionPoint.left
      })
    $(@adder).removeClass(ADDER_HIDE_CLASS)

  # Public: Hide the adder.
  #
  # Returns nothing.
  hide: =>
    $(@adder).addClass(ADDER_HIDE_CLASS)

  # Public: Returns true if the adder is currently displayed, false otherwise.
  #
  # Examples
  #
  #   adder.show()
  #   adder.isShown() # => true
  #
  #   adder.hide()
  #   adder.isShown() # => false
  #
  # Returns true if the adder is visible.
  isShown: ->
    not $(@adder).hasClass(ADDER_HIDE_CLASS)

  # Event callback: called when the mouse button is depressed on the adder.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  _onMousedown: (event) =>
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    event?.preventDefault()
    # Prevent the selection code from firing when the mouse button is released
    @core.ignoreMouseup = true

  # Event callback: called when the adder is clicked. The click event is used as
  # well as the mousedown so that we get the :active state on the @adder when
  # clicked.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  _onClick: (event) =>
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    event?.preventDefault()

    # Hide the adder
    this.hide()
    @core.ignoreMouseup = false

    # Create a new annotation
    @core.annotations.create(@core.selectedSkeleton)


# This is a core plugin (registered by default with Annotator), so we don't
# register here. If you're writing a plugin of your own, please refer to a
# non-core plugin (such as Document or Store) to see how to register your plugin
# with Annotator.

module.exports = Adder
