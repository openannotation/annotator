# annotator.ui package

.. function:: annotator.ui.main(\[options\])

> A module that provides a default user interface for Annotator that
> allows users to create annotations by selecting text within (a part
> of) the document.
>
> Example:
>
>     app.include(annotator.ui.main);
>
> param Object options  
>
> > <div class="attribute">
> >
> > options.element
> >
> > A DOM element to which event listeners are bound. Defaults to
> > `document.body`, allowing annotation of the whole document.
> >
> > </div>
> >
> > <div class="attribute">
> >
> > options.editorExtensions
> >
> > An array of editor extensions. See the `~annotator.ui.editor.Editor`
> > documentation for details of editor extensions.
> >
> > </div>
> >
> > <div class="attribute">
> >
> > options.viewerExtensions
> >
> > An array of viewer extensions. See the `~annotator.ui.viewer.Viewer`
> > documentation for details of viewer extensions.
> >
> > </div>

.. function:: annotator.ui.markdown.render(annotation)

> Render an annotation to HTML, converting annotation text from Markdown
> if Showdown is available in the page.
>
> returns  
> Rendered HTML.
>
> rtype  
> String

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

.. function:: annotator.ui.tags.viewerExtension(viewer)

> An extension for the `~annotator.ui.viewer.Viewer` that displays any
> tags stored as an array of strings in the annotation's `tags`
> property.
>
> **Usage**:
>
>     app.include(annotator.ui.main, {
>         viewerExtensions: [annotator.ui.tags.viewerExtension]
>     })

<div class="function">

annotator.ui.tags.editorExtension(editor)

An extension for the `~annotator.ui.editor.Editor` that allows editing a
set of space-delimited tags, retrieved from and saved to the
annotation's `tags` property.

**Usage**:

    app.include(annotator.ui.main, {
        editorExtensions: [annotator.ui.tags.editorExtension]
    })

</div>
