$ = jQuery

class Annotator.Plugins.Tags extends Delegator
  events:
    'annotationEditorShown': 'updateEditor'

  constructor: (element, options) ->
    super
    this.addEvents()

  updateEditor: (e, editorElement, annotation) =>
    $("<input type='text'>").appendTo(editorElement)