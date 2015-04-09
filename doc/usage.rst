Configuring and using Annotator
===============================

This document assumes you have already downloaded and installed Annotator into
your web page. If you have not, please read :doc:`installing` before continuing.

The basics
----------

When Annotator is loaded into the page, it exposes a single root object,
``annotator``, which provides access to the main ``annotator.App`` object and
all other included components.

To create a new ``App`` instance with a default configuration for the whole
document, you can run::

   var ann = new annotator.App(document.body);

You can configure the default ``App`` using the ``options`` argument to the
constructor::

   var ann = new annotator.App(document.body, {
      readOnly: true
   });

.. todo:: add JSDoc links here

See the docs for ``App`` for more details.
