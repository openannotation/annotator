``annotator.ui.main``
=====================

This module provides a user interface for the application, allowing users to
make annotations on a document or an element within the document. It can be used
as follows::

    app.include(annotator.ui.main);

By default, the module will set up event listeners on the document ``body`` so
that when the user makes a selection they will be prompted to create an
annotation. It is also possible to ask the module to only allow creation of
annotations within a specific element on the page::

    app.include(annotator.ui.main, {
        element: document.querySelector('#main')
    });


The module provides just one possible configuration of the various components in
the `annotator.ui` package, and users with more advanced needs may wish to
create their own modules that use those components (which include
:class:`~annotator.ui.textselector.TextSelector`,
:class:`~annotator.ui.adder.Adder`,
:class:`~annotator.ui.highlighter.Highlighter`,
:class:`~annotator.ui.viewer.Viewer`, and :class:`~annotator.ui.editor.Editor`).

Viewer/editor extensions
------------------------

The `annotator.ui` package contains a number of extensions for the
:class:`~annotator.ui.viewer.Viewer` and :class:`~annotator.ui.editor.Editor`,
which extend the functionality. These include:

-  :func:`annotator.ui.tags.viewerExtension`: A viewer extension that displays
   any tags stored on annotations.

-  :func:`annotator.ui.tags.editorExtension`: An editor extension that provides
   a field for editing annotation tags.

-  :func:`annotator.ui.markdown.viewerExtension`: A viewer extension that
   depends on Showdown_, and makes the viewer render Markdown_ annotation
   bodies.

.. _Showdown: https://github.com/showdownjs/showdown
.. _Markdown: https://daringfireball.net/projects/markdown/

These can be used by passing them to the relevant options of
``annotator.ui.main``::

    app.include(annotator.ui.main, {
        editorExtensions: [annotator.ui.tags.editorExtension],
        viewerExtensions: [
            annotator.ui.markdown.viewerExtension,
            annotator.ui.tags.viewerExtension
        ]
    });
