# `annotator.ui.main`

This module provides a user interface for the application, allowing
users to make annotations on a document or an element within the
document. It can be used as follows:

    app.include(annotator.ui.main);

By default, the module will set up event listeners on the document
`body` so that when the user makes a selection they will be prompted to
create an annotation. It is also possible to ask the module to only
allow creation of annotations within a specific element on the page:

    app.include(annotator.ui.main, {
        element: document.querySelector('#main')
    });

The module provides just one possible configuration of the various
components in the <span class="title-ref">annotator.ui</span> package,
and users with more advanced needs may wish to create their own modules
that use those components (which include
`~annotator.ui.textselector.TextSelector`, `~annotator.ui.adder.Adder`,
`~annotator.ui.highlighter.Highlighter`, `~annotator.ui.viewer.Viewer`,
and `~annotator.ui.editor.Editor`).

## Viewer/editor extensions

The <span class="title-ref">annotator.ui</span> package contains a
number of extensions for the `~annotator.ui.viewer.Viewer` and
`~annotator.ui.editor.Editor`, which extend the functionality. These
include:

- `annotator.ui.tags.viewerExtension`: A viewer extension that displays
  any tags stored on annotations.
- `annotator.ui.tags.editorExtension`: An editor extension that provides
  a field for editing annotation tags.
- `annotator.ui.markdown.viewerExtension`: A viewer extension that
  depends on [Showdown](https://github.com/showdownjs/showdown), and
  makes the viewer render
  [Markdown](https://daringfireball.net/projects/markdown/) annotation
  bodies.

These can be used by passing them to the relevant options of
`annotator.ui.main`:

    app.include(annotator.ui.main, {
        editorExtensions: [annotator.ui.tags.editorExtension],
        viewerExtensions: [
            annotator.ui.markdown.viewerExtension,
            annotator.ui.tags.viewerExtension
        ]
    });
