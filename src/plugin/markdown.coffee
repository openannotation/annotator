# Plugin that renders annotation comments displayed in the Viewer in Markdown.
# Requires Showdown library to be present in the page when initialised.
class Annotator.Plugin.Markdown extends Annotator.Plugin
  # Events to be bound to the @element.
  events:
    'annotationViewerShown': 'updateViewer'

  # Public: Initailises an instance of the Markdown plugin.
  #
  # element - The Annotator#element.
  # options - An options Object (there are currently no options).
  #
  # Examples
  #
  #   plugin = new Annotator.Plugin.Markdown(annotator.element)
  #
  # Returns a new instance of Annotator.Plugin.Markdown.
  constructor: (element, options) ->
    if Showdown?
      super
      @converter = new Showdown.converter()
    else
      console.error "To use the Markdown plugin, you must include Showdown into the page first."

  # Annotator event callback. Updates the displayed comments with a Markdown
  # rendered version.
  #
  # Returns nothing
  updateViewer: (viewerElement, annotations) =>
    textContainers = $(viewerElement).find('.annotator-ann-text')

    for t in textContainers
      ann = $(t).parent().data('annotation')
      markdown = @converter.makeHtml ann.text
      $(t).html markdown
