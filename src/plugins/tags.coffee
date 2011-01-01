$ = jQuery

class Annotator.Plugins.Tags extends Delegator
  events:
    'annotationViewerShown':  'updateViewer'
    'annotationEditorShown':  'updateEditor'
    'annotationEditorHidden': 'clearEditor'
    'annotationEditorSubmit': 'setAnnotationTags'

  constructor: (element, options) ->
    super
    this.addEvents()
    this.tagSrc = "<input type='text' class='annotator-editor-tags' placeholder='tags&hellip;'>"

  updateEditor: (e, editorElement, annotation) =>
    if not this.tags
      controls = $(editorElement).find('.annotator-editor-controls')
      this.tags = $(this.tagSrc).insertBefore(controls).get(0)

    if annotation?.tags?
      $(this.tags).val(this.stringifyTags(annotation.tags))

  clearEditor: (e, editorElement) =>
    if this.tags
      $(this.tags).val('')

  setAnnotationTags: (e, editorElement, annotation) =>
    if this.tags
      annotation.tags = this.parseTags($(this.tags).val())

  parseTags: (string) ->
    string.split(/\s+/)

  stringifyTags: (array) ->
    array.join(" ")

  updateViewer: ->
