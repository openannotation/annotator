.. default-domain: js

annotator.ui.markdown package
=============================

..  function:: annotator.ui.markdown.render(annotation)
    
    Render an annotation to HTML, converting annotation text from Markdown if
    Showdown is available in the page.

    :returns: Rendered HTML.
    :rtype: String


..  function:: annotator.ui.markdown.viewerExtension(viewer)

    An extension for the :class:`~annotator.ui.viewer.Viewer`. Allows the viewer
    to interpret annotation text as `Markdown`_ and uses the `Showdown`_ library
    if present in the page to render annotations with Markdown text as HTML.
    
    .. _Markdown: https://daringfireball.net/projects/markdown/
    .. _Showdown: https://github.com/showdownjs/showdown
    
    **Usage**::
    
        app.include(annotator.ui.main, {
            viewerExtensions: [annotator.ui.markdown.viewerExtension]
        });


