
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

  show: =>
    $(@element).removeClass('annotator-hide');

  hide: =>
    $(@element).addClass('annotator-hide');

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
