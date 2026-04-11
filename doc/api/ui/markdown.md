# annotator.ui.markdown package

<div class="function">

annotator.ui.markdown.render(annotation)

Render an annotation to HTML, converting annotation text from Markdown
if Showdown is available in the page.

returns  
Rendered HTML.

rtype  
String

</div>

<div class="function">

annotator.ui.markdown.viewerExtension(viewer)

An extension for the `~annotator.ui.viewer.Viewer`. Allows the viewer to
interpret annotation text as
[Markdown](https://daringfireball.net/projects/markdown/) and uses the
[Showdown](https://github.com/showdownjs/showdown) library if present in
the page to render annotations with Markdown text as HTML.

**Usage**:

    app.include(annotator.ui.main, {
        viewerExtensions: [annotator.ui.markdown.viewerExtension]
    });

</div>
