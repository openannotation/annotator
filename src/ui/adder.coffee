Widget = require('./widget.coffee').Widget
Util = require('../util')

$ = Util.$
_t = Util.TranslationString

NS = 'annotator-adder'


# Adder shows and hides an annotation adder button that can be clicked on to
# create an annotation.
class Adder extends Widget
  @template:
    """
    <div class="annotator-adder annotator-hide">
      <button type="button">#{_t('Annotate')}</button>
    </div>
    """

  # Configuration options
  @options:
    onCreate: null # Callback, called when the user clicks the adder when an
                   # annotation is loaded.

  constructor: (options) ->
    super

    @ignoreMouseup = false
    @annotation = null

    if @options.onCreate?
      @onCreate = @options.onCreate

    @element
      .on("click.#{NS}", 'button', (e) => this._onClick(e))
      .on("mousedown.#{NS}", 'button', (e) => this._onMousedown(e))

    @document = @element[0].ownerDocument
    $(@document.body).on("mouseup.#{NS}", this._onMouseup)
    this.render()

  destroy: ->
    @element.off(".#{NS}")
    $(@document.body).off(".#{NS}")
    super

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
    if event.which > 1
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
    if event.which > 1
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
    if event.which > 1
      return

    event?.preventDefault()

    # Hide the adder
    this.hide()
    @ignoreMouseup = false

    # Create a new annotation
    if @annotation? and typeof @onCreate == 'function'
      @onCreate(@annotation, event)


exports.Adder = Adder
