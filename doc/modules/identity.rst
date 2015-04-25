``annotator.identity.simple``
=============================

This module configures an identity policy that considers the identity of the
current user to be an opaque identifier. By default the identity is
unconfigured, but can be set.

Example
-------

::

    app.include(annotator.identity.simple);
    app
    .start()
    .then(function () {
        app.ident.identity = 'joebloggs';
    });

See :func:`annotator.identity.simple` for full API documentation.
