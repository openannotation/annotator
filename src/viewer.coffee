
class Annotator.Viewer extends Delegator
  events:
    ".annotator-edit click":   "onEditClick"
    ".annotator-delete click": "onDeleteClick"

  classes:
    hide: 'annotator-hide'
    showControls: 'annotator-visible'

  html:
    element:"""
            <div class="annotator-outer annotator-viewer">
              <ul class="annotator-widget"></ul>
            </div>
            """
    item:   """
            <li class="annotator-annotation">
              <span class="annotator-controls">
                <button class="annotator-edit">Edit</button>
                <button class="annotator-delete">Delete</button>
              </span>
            </li>
            """

  constructor: (options) ->
    super $(@html.element)[0], options

    @item   = $(@html.item)[0]
    @fields = []
    @annotations = []

    # Setup the default view field.
    this.addField({
      type: 'textarea',
      load: (field, annotation) ->
        $(field).escape(annotation.text || '')
    })

  show: (event) =>
    event?.preventDefault()

    controls = $(@element)
      .find('.annotator-controls')
      .addClass(@classes.showControls)
    setTimeout((=> controls.removeClass(@classes.showControls)), 500)

    $(@element).removeClass(@classes.hide).trigger('show')

  isShown: ->
    not $(@element).hasClass(@classes.hide)

  hide: (event) =>
    event?.preventDefault()
    $(@element).addClass(@classes.hide).trigger('hide')

  load: (annotations) =>
    @annotations = annotations || []

    list = $(@element).find('ul:first').empty()
    for annotation in @annotations
      item = $(@item).clone().appendTo(list).data('annotation', annotation)
      controls = item.find('.annotator-controls')

      for field in @fields
        element = $(field.element).clone().insertBefore(controls)[0]
        field.load(element, annotation)

    $(@element).trigger('load', [@annotations])

    this.show();

  addField: (options) ->
    field = $.extend({
      load: ->
    }, options)

    field.element = $('<div />')[0]
    @fields.push field
    field.element

  onEditClick: (event) =>
    this.onButtonClick(event, 'edit')

  onDeleteClick: (event) =>
    this.onButtonClick(event, 'delete')

  onButtonClick: (event, type) ->
    item = $(event.target).parents('.annotator-annotation')

    $(@element).trigger(type, [item.data('annotation')])
