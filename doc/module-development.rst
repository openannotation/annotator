Module development
==================

The basics
----------

An Annotator module is a function which can be passed to
:func:`~annotator.App.prototype.include` in order to extend the functionality of
an Annotator application. Modules can:

- be notified and make changes to annotations as they are created or modified
- provide alternative user interfaces
- provide alternative storage backends for annotations
- change how Annotator decides what permissions an annotating user has

and plenty more.

The simplest possible Annotator module looks like this::

    function myModule() {
        return {};
    }

This clearly won't do very much, but we can include it in an application::

    app.include(myModule);

If we want to do something more interesting, we have to provide some module
functionality. There are essentially two primary ways of doing this:

1. module hooks
2. component registration

Unless you are replacing core functionality of Annotator (writing a storage
component, for example) you probably want to use module hooks. Module hooks are
functions which you can expose from your module which will be run by the
:class:`~annotator.App` when important things happen. For example, here's a
module which will log ``Hello, world!`` to the console when the application
starts::

    function helloWorld() {
        return {
            start: function (registry) {
                console.log("Hello, world!");
            }
        };
    }

Just as before, we can include it in an application using
:func:`~annotator.App.prototype.include`::

    app.include(helloWorld);

Now, when you run ``app.start();``, this module will log ``Hello, world!`` to
the console.

Or, here's another example that uses the `HTML5 Audio API`_ to play a sound
every time a new annotation is made [#1]_::

    function fanfare(options) {
        options = options || {};
        options.url = options.url || 'trumpets.mp3';

        return {
            onAnnotationCreated: function (annotation) {
                var audio = new Audio(options.url);
                audio.play();
            }
        };
    }

Here we've added an ``options`` argument to the module function so we can
configure the module when it's included in our application::

    app.include(fanfare, {
        url: "brass_band.wav"
    });

You might have noticed that the ``onAnnotationCreated`` module hook function
here receives one argument, ``annotation``. Similarly, the ``start`` module hook
function in the previous example received a ``registry`` argument. You can find
out which arguments are passed to which module hooks in :ref:`module-hooks`,
below.

.. _HTML5 Audio API: https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API


Loading custom modules
----------------------

When you write a custom module, you'll end up with a JavaScript function which
you need to reference when you build your application. In the examples above
we've just defined a function and then used it straight away. This is probably
fine for small examples, but when things get a bit more complicated you might
want to put your modules in a namespace.

For example, if you were working on an application for annotating Shakespeare's
plays, you might put all your modules in a namespace called ``shakespeare``::

    var shakespeare = {};
    shakespeare.fanfare = function fanfare(options) {
        ...
    };
    shakespeare.addSceneData = function addSceneData(options) {
        ...
    };

You get the idea. You can now :func:`~annotator.App.prototype.include` these
modules directly from the namespace::

    app.include(shakespeare.fanfare, {
        url: "elizabethan_sackbuts.mp3"
    });
    app.include(shakespeare.addSceneData);

All the modules that ship with Annotator are placed within the ``annotator``
namespace. If you write and publish your own modules, be aware that you don't
need to put your modules in the ``annotator`` namespace for them to work.


.. _module-hooks:

Module hooks
------------

This is a list of module hooks, when they are called, and what arguments they
receive.


+----------------------------------+---------------------------------------------------------------------------------+-------------------------------------------------------------------+
| Name                             | Arguments                                                                       | Description                                                       |
+==================================+=================================================================================+===================================================================+
| ``configure(registry)``          | - ``registry``: the :class:`application registry <annotator.registry.Registry>` | Called when the plugin is included. If you are going to register  |
|                                  |                                                                                 | components with the registry, you should do so in the             |
|                                  |                                                                                 | ``configure`` module hook.                                        |
+----------------------------------+---------------------------------------------------------------------------------+-------------------------------------------------------------------+
| ``start(registry)``              | - ``registry``: the :class:`application registry <annotator.registry.Registry>` | Called when :func:`~annotator.App.prototype.start` is called.     |
+----------------------------------+---------------------------------------------------------------------------------+-------------------------------------------------------------------+

.. todo:: Put the rest of these in the table.

``beforeAnnotationCreated(annotation)``
    called immediately before an annotation is created. If you need to modify
    the annotation before it is saved use this event.
``annotationCreated(annotation)``
    called when the annotation is created use this to store the annotations.
``beforeAnnotationUpdated(annotation)``
    as above, but just before an existing annotation is saved.
``annotationUpdated(annotation)``
    as above, but for an existing annotation which has just been edited.
``beforeAnnotationDeleted(annotation)``
    as above, but just before an existing annotation is deleted.
``annotationDeleted(annotation)``
    called when the user deletes an annotation.

.. rubric:: Footnotes

.. [#1] Yes, this might be quite annoying. Probably not an example to copy
        wholesale into your real application...
