Configuring and using Annotator
===============================

This document assumes you have already downloaded and installed Annotator.
If you have not done so, please read :doc:`installing` before continuing.

The basics
----------

.. |App| replace:: :class:`~annotator.App`

When Annotator is loaded into the page, it exposes a single object,
``annotator``, which provides access to the main :class:`annotator.App` object
and all other included components. To use Annotator, you must configure and
start an |App|. At its simplest, that looks like this::

   var app = new annotator.App();
   app.start();

You probably want to keep reading if you want your Annotator installation to be
useful straight away, as by default an |App| is extremely minimal. You can can
easily add functionality from an Annotator :term:`module`, an independent
components that you can load into your :term:`application`. For example, here
we create an |App| that uses the default Annotator user interface
(:func:`annotator.ui.main`), and the :func:`annotator.storage.http` storage
component in order to save annotations to a remote server::

   var app = new annotator.App();
   app.include(annotator.ui.main);
   app.include(annotator.storage.http);
   app.start();

This is how most Annotator deployments will look: create an |App|, configure it
with :func:`~annotator.App.prototype.include`, and then run it using
:func:`~annotator.App.prototype.start`.

If you want to do something (for example, load annotations from storage) when
the |App| has started, you can take advantage of the fact that
:func:`~annotator.App.prototype.start` returns a :term:`Promise`. Extending our
example above::

   var app = new annotator.App();
   app.include(annotator.ui.main);
   app.include(annotator.storage.http);
   app
   .start()
   .then(function () {
        app.annotations.load();
   });


This example calls :func:`~annotator.storage.StorageAdapter.prototype.load` on
the ``annotations`` property of the |App|. This will load annotations from
whatever storage component you have configured.

Most functionality in Annotator comes from these modules, so you should
familiarise yourself with what's available to you in order to make the most of
Annotator. Next we talk about how to configure modules when you add them to your
|App|.


Configuring modules
-------------------

Once you have a basic Annotator application working, you can begin to customize
it. Some modules can be configured, and you can find out what options they
accept in the relevant :doc:`api/index`.

For example, here are the options accepted by the :func:`annotator.storage.http`
module: :data:`annotator.storage.HttpStorage.options`. Let's say we have an
`annotator-store server`_ running at ``http://example.com/api``. We can
configure the :func:`~annotator.storage.http` module to address it like so::

   app.include(annotator.storage.http, {
       prefix: 'http://example.com/api'
   });

.. _annotator-store server: https://github.com/openannotation/annotator-store


Writing modules
---------------

If you've looked through the available :doc:`modules` and haven't found what you
want, you can write your own module. Read more about that in
:doc:`module-development`.
