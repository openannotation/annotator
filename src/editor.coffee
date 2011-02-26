
class Annotator.Editor extends Delegator
  events:
    "form submit":             "submit"
    ".annotator-save click":   "submit"
    ".annotator-cancel click": "hide"
    "textarea keydown":        "processKeypress"

  html: """
        <div class="annotator-outer annotator-editor">
          <div class="annotator-widget">
            <ul>
              <li>
                <textarea cols="20" rows="4" placeholder="Comments…"></textarea>
              </li>
            </ul>
            <div class="annotator-controls">
              <a href="#cancel" class="annotator-cancel">Cancel</a>
              <a href="#save" class="annotator-save annotator-focus">Save</a>
            </div>
            <span class="annotator-resize"></span>
          </div>
        <div>
        """

  options: {} # Configuration options

  constructor: (options) ->
    super $(@html)[0], options

    @fields = []
    @annotation = {}

    this.setupDragabbles()

  show: =>
    $(@element)
     .removeClass('annotator-hide')
     .trigger('show')
     .find(':input:first')
       .focus();

  hide: =>
    $(@element).addClass('annotator-hide').trigger('hide')

  load: (annotation) =>
    @annotation = annotation

    for field in @fields
      field.load(field.element, @annotation)

    this.show();

  submit: (event) =>
    event?.preventDefault()

    for field in @fields
      field.submit(field.element, @annotation)

    this.hide()

  addField: (options) ->
    field = $.extend({
      id:     'annotator-field-' + (new Date()).getTime()
      type:   'input'
      label:  ''
      load:   ->
      submit: ->
    }, options)

    input = null
    element = $('<li />')
    field.element = element[0]

    switch (field.type)
      when 'textarea'          then input = $('<textarea />')
      when 'input', 'checkbox' then input = $('<input />')

    element.append(input);

    input.attr({
      id: field.id
      placeholder: field.label
    })

    if field.type == 'checkbox'
      input[0].type = 'checkbox'
      element.append($('<label />', {for: field.id}))

    $(@element).find('ul:first').append(element)

    @fields.push field

  processKeypress: (event) =>
    if event.keyCode is 27 # "Escape" key => abort.
      this.hide()
    else if event.keyCode is 13 and !event.shiftKey
      # If "return" was pressed without the shift key, we're done.
      this.submit()

  setupDragabbles: () ->
    mousedown = null
    editor    = $(@element)
    resize    = editor.find('.annotator-resize')
    textarea  = editor.find('textarea:first')
    controls  = editor.find('.annotator-controls')
    throttle  = false

    onMousedown = (event) ->
      if event.target == this
        mousedown = {
          element: this
          top:     event.pageY
          left:    event.pageX
        }

        $(window).bind({
          'mouseup.annotator-editor-resize':   onMouseup
          'mousemove.annotator-editor-resize': onMousemove
        })
        event.preventDefault();

    onMouseup = ->
      mousedown = null;
      $(window).unbind '.annotator-editor-resize'

    onMousemove = (event) ->
      console.log 'oops'
      if mousedown and throttle == false
        diff = {
          top:  event.pageY - mousedown.top
          left: event.pageX - mousedown.left
        }

        if mousedown.element == resize[0]
          height = textarea.outerHeight()
          width  = textarea.outerWidth()

          textarea.height(height - diff.top)
          textarea.width(width + diff.left)

          # Only update the mousedown object if the dimensions
          # have changed, otherwise they have reached thier minimum
          # values.
          mousedown.top  = event.pageY unless textarea.outerHeight() == height
          mousedown.left = event.pageX unless textarea.outerWidth()  == width

        else if mousedown.element == controls[0]
          editor.css({
            top:  parseInt(editor.css('top'), 10)  + diff.top
            left: parseInt(editor.css('left'), 10) + diff.left
          })

          mousedown.top  = event.pageY
          mousedown.left = event.pageX

        throttle = true;
        setTimeout(->
          throttle = false
        , 1000/60);

    resize.bind   'mousedown', onMousedown
    controls.bind 'mousedown', onMousedown
