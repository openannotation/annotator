class Annotator.Plugin.Tags extends Annotator.Plugin

  pluginInit: ->
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
    string.split(/\s+/)

  stringifyTags: (array) ->
    array.join(" ")

  updateViewer: (field, annotation) ->
    $(field).addClass('annotator-tags').html(->
      string = ''

      if annotation.tags and $.isArray(annotation.tags)
        string = $.map(annotation.tags,(tag) ->
          '<span class="annotator-tag">' + Annotator.$.escape(tag) + '</span>'
        ).join(' ')

      string
    )

