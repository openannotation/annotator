$ = jQuery

class Annotator.Plugins.Markdown extends Delegator
  events:
    'annotationViewerShown': 'updateViewer'

  constructor: (element, options) ->
    if Showdown?
      super
      this.addEvents()
      @converter = new Showdown.converter()
    else
      alert "To use the Markdown plugin, you must include Showdown into the page first."

  updateViewer: (e, viewerElement, annotations) =>
    textContainers = $(viewerElement).find('div.annot-text')

    for t in textContainers
      ann = $(t).parent().data('annotation')
      markdown = @converter.makeHtml ann.text
      $(t).html markdown