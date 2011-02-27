class Annotator.Plugin.Tags extends Annotator.Plugin

  pluginInit: ->
    return unless Annotator.supported()

    @field = @annotator.editor.addField({
      label:  'Add some tags here\u2026'
      load:   this.updateField
      submit: this.setAnnotationTags
    })

    @annotator.viewer.addField({
      load: this.updateViewer
    })

    @input = $(@field).find(':input')

  updateField: (field, annotation) =>
    value = ''
    value = this.stringifyTags(annotation.tags) if annotation.tags

    @input.val(value)

  setAnnotationTags: (field, annotation) =>
    annotation.tags = this.parseTags(@input.val())

  parseTags: (string) ->
    string = $.trim(string)

    tags = []
    tags = string.split(/\s+/) if string
    tags

  stringifyTags: (array) ->
    array.join(" ")

  updateViewer: (field, annotation) ->
    field = $(field)

    if annotation.tags and $.isArray(annotation.tags) and annotation.tags.length
      field.addClass('annotator-tags').html(->
        string = $.map(annotation.tags,(tag) ->
            '<span class="annotator-tag">' + Annotator.$.escape(tag) + '</span>'
        ).join(' ')
      )
    else
      field.remove()

