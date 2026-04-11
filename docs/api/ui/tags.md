# annotator.ui.tags package

<div class="function">

annotator.ui.tags.viewerExtension(viewer)

An extension for the `~annotator.ui.viewer.Viewer` that displays any
tags stored as an array of strings in the annotation's `tags` property.

**Usage**:

    app.include(annotator.ui.main, {
        viewerExtensions: [annotator.ui.tags.viewerExtension]
    })

</div>

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
