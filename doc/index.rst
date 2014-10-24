Annotator documentation
=======================

.. warning:: Beware: rapidly changing documentation!

   This is the bleeding-edge documentation for Annotator which will be changing
   rapidly as we home in on Annotator v2.0. Information here may be inaccurate,
   prone to change, and otherwise unreliable. You may well want to consult `the
   stable documentation`_ instead.

.. _the stable documentation: http://docs.annotatorjs.org/en/v1.2.x/

.. highlight:: js

This is where you can find out about Annotator, an open-source JavaScript
library for building annotation systems on the web. At its simplest, Annotator
allows you to start selecting text and annotating a document with a few lines of
code:

.. code::

    var annotator = new Annotator(document.body);

But Annotator is also a loosely-coupled set of components that you can use to
build your own annotation-based applications:

.. code::

   var annotator = new Annotator.Core.Annotator()
       .setStorage(Annotator.Storage.HTTPStorage)
       .addPlugin(Annotator.Plugin.DefaultUI(document.body))
       .addPlugin(Annotator.Plugin.Filter())
       .addPlugin(function (registry) {
           return {
               onAnnotationCreated: function (ann) {
                   console.log("Annotation was created: ", ann);
               }
           }
       });

You can use the table of contents below to learn how to use Annotator and its
various components.

Contents:

.. toctree::
   :maxdepth: 2

   getting-started
   annotation-format
   authentication
   permissions
   internationalization

   plugins/index
   storage/index
   hacking/plugin-development

   roadmap

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
