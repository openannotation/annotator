# Wrapper around the Annotator.Editor class. Augments the interface with
# tap friendly buttons and touch event handlers. Rather than creating a new
# class or extending the Annotator.Editor class we use the wrapper to
# change the current interface without having to heavily monkey patch the
# Annotator core.
class Annotator.Plugin.Touch.Editor extends Annotator.Delegator
  # Export local globals. These are only available within the class closure.
  _t = Annotator._t
  jQuery = Annotator.$
  Touch  = Annotator.Plugin.Touch

  # DOM event handlers and event subscriptions.
  events:
    # Use click for the overlay rather than tap to allow scrolling.
    "click": "_onOverlayTap"
    ".annotator-save tap": "_onSubmit"
    ".annotator-cancel tap": "_onCancel"
    ".annotator-quote-toggle tap": "_onExpandTap"

  # Classes for managing the state of the application.
  classes:
    expand: "annotator-touch-expand"

  # General templates.
  templates:
    quote: """
    <button class="annotator-quote-toggle">""" + _t("expand") + """</button>
    <span class="quote"></span>
    """

  # Sets up a new instance of the editor wrapper and augments the @editor
  # element with the new interface elements.
  #
  # editor  - An instance of Annotator.Editor.
  # options - An object of options.
  #
  # Returns nothing.
  constructor: (@editor, options) ->
    super @editor.element[0], options
    @element.addClass("annotator-touch-editor")
    @element.wrapInner('<div class="annotator-touch-widget" />')
    @element.find("form").addClass("annotator-touch-widget-inner")
    @element.find(".annotator-controls a").addClass("annotator-button")

    # Remove the "return to submit" listener.
    @element.undelegate("textarea", "keydown")
    @on "hide", => @element.find(":focus").blur()

    @_setupQuoteField()
    @_setupAndroidRedrawHack()

  # Expands the quote field to display more than one line.
  #
  # Examples
  #
  #   editor.showQuote()
  #
  # Returns itself.
  showQuote: ->
    @quote.addClass(@classes.expand)
    @quote.find("button").text _t("Collapse")
    this

  # Collapses the quote field to display only one line.
  #
  # Examples
  #
  #   editor.hideQuote()
  #
  # Returns itself.
  hideQuote: ->
    @quote.removeClass(@classes.expand)
    @quote.find("button").text _t("Expand")
    this

  # Public: Checks to see if the quote is expanded/collapsed.
  #
  # Returns true if the quote is collapsed.
  isQuoteHidden: ->
    not @quote.hasClass(@classes.expand)

  # Adds the @quote field to the @editor. Should only be called once in the
  # constructor.
  #
  # Returns nothing.
  _setupQuoteField: ->
    @quote = jQuery @editor.addField
      id: 'quote'
      load: (field, annotation) =>
        @hideQuote()
        @quote.find('span').html Annotator.Util.escape(annotation.quote || '')
        @quote.find("button").toggle(@_isTruncated())

    @quote.empty().addClass("annotator-item-quote")
    @quote.append(@templates.quote)

  # Sets up a very spcific hack for android to redraw the view when the
  # editor is displayed. The Android browser overlays it's own text box
  # on to of the editor when focused, however this does not scroll with the
  # rest of the UI. So to trigger this we slighly change the size of the
  # focused input on scroll so the box is redrawn.
  #
  # This was tested on a Galaxy Tab running 3.2, hopeully this will be
  # resolved in a future release.
  #
  # Returns nothing.
  _setupAndroidRedrawHack: ->
    if Touch.isAndroid()
      timer = null
      check = => timer = null; @_triggerAndroidRedraw()
      jQuery(window).bind "scroll", ->
        timer = setTimeout(check, 100) unless timer

  # Forces the Android browser to redraw it's custom text input that it
  # overlays on top of the webkit fields. See @_setupAndroidRedrawHack()
  # for details.
  #
  # Returns nothing.
  _triggerAndroidRedraw: =>
    @_input   = @element.find(":input:first") unless @_input
    @_default = parseFloat(@_input.css "padding-top") unless @_default
    @_multiplier = (@_multiplier or 1) * -1
    @_input[0].style.paddingTop = (@_default + @_multiplier) + "px"
    @_input[0].style.paddingTop = (@_default - @_multiplier) + "px"

  # Determines if the quoted text is larger than the containing element
  # when collapsed. This can be used to display the expand/collapse button.
  #
  # Returns true if the text is larger than the containing element.
  _isTruncated: ->
    isHidden = @isQuoteHidden()

    @hideQuote() unless isHidden
    truncatedHeight = @quote.height()
    @showQuote()
    expandedHeight = @quote.height()

    # Restore previous state.
    if isHidden then @hideQuote() else @showQuote()

    return expandedHeight > truncatedHeight

  # Event handler for the expand button in the quote field.
  #
  # event - A jQuery.Event tap event object.
  #
  # Returns nothing.
  _onExpandTap: (event) =>
    event.preventDefault()
    event.stopPropagation()
    if @isQuoteHidden() then @showQuote() else @hideQuote()

  # Event handler for the submit button in the editor.
  #
  # event - A jQuery.Event tap event object.
  #
  # Returns nothing.
  _onSubmit: (event) =>
    event.preventDefault()
    @editor.submit()

  # Event handler for the cancel button in the editor.
  #
  # event - A jQuery.Event tap event object.
  #
  # Returns nothing.
  _onCancel: (event) =>
    event.preventDefault()
    @editor.hide()

  # Event handler for the overlay.
  #
  # event - A jQuery.Event click event object.
  #
  # Returns nothing.
  _onOverlayTap: (event) =>
    @editor.hide() if event.target is @element[0]
