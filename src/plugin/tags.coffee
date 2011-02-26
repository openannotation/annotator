class Annotator.Plugin.Tags extends Annotator.Plugin
  events:
    'annotationViewerShown':  'updateViewer'

  pluginInit: ->
    @field = @annotator.editor.addField({
      label:  'tags'
      load:   this.updateField
      submit: this.setAnnotationTags
    })

    @input = $(@field).find(':input')

  updateField: (field, annotation) =>
    value = ''
    value = this.stringifyTags(annotation.tags) if annotation.tags

    @input.val(value)

  setAnnotationTags: (field, annotation) =>
    annotation.tags = this.parseTags(@input.val())

  parseTags: (string) ->
    string.split(/\s+/)

  stringifyTags: (array) ->
    array.join(" ")

  updateViewer: (e, viewerElement, annotations) ->
    annElements = $(viewerElement).find('.annotator-ann')

    for i in [0...annElements.length]
      tags    = annotations[i].tags
      tagStr  = tags?.join(", ")
      $textEl = annElements.eq(i).find('.annotator-ann-text')

      if tagStr and tagStr != ""
        $("<div class='annotator-ann-tags'>#{tags.join(", ")}</div>").insertAfter($textEl)
