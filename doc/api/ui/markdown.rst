.. default-domain: js

annotator.ui.markdown package
=============================

..  function:: annotator.ui.markdown.renderer(annotation)
    
    A renderer for the :class:`~annotator.ui.viewer.Viewer` which interprets
    annotation text as `Markdown`_ and uses the `Showdown`_ library if present in
    the page to render annotations with Markdown text as HTML.
    
    .. _Markdown: https://daringfireball.net/projects/markdown/
    .. _Showdown: https://github.com/showdownjs/showdown
    
    **Usage**::
    
        app.include(annotator.ui.main, {
            viewerRenderer: annotator.ui.markdown.renderer
        });


