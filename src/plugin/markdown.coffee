class Annotator.Plugin.Markdown extends Annotator.Plugin
  events:
    'annotationViewerShown': 'updateViewer'

  constructor: (element, options) ->
    if Showdown?
      super
      this.addEvents()
      @converter = new Showdown.converter()
    else
      console.error "To use the Markdown plugin, you must include Showdown into the page first."

  updateViewer: (e, viewerElement, annotations) =>
    textContainers = $(viewerElement).find('.annotator-ann-text')

    for t in textContainers
      ann = $(t).parent().data('annotation')
      markdown = @converter.makeHtml ann.text
      $(t).html markdown
