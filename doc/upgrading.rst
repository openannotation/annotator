Upgrading guide
===============

Annotator 2.0 represents a substantial change from the 1.2 series, and
developers are advised to read this document before attempting to upgrade
existing installations.

In addition, plugin authors will want to read this document in order to
understand how to update their plugins to work with the new Annotator.

.. contents::


Motivation
----------

The architecture of the first version of Annotator dates back to 2009, when the
Annotator application was developed to enable annotation in a project called
"Open Shakespeare". At the time, Annotator was designed primarily as a drop-in
annotation application, with only limited support for customization.

Over several years, Annotator gained support for plugins that allowed
developers to customize and extend the behavior of the application.

In order to ensure a stable platform for future development, we have made some
substantial changes to Annotator's architecture. Unfortunately, this means that
the upgrade from 1.2 to 2.0 will not always be painless.

If you're very happy with Annotator 1.2 as it is now, you may wish to continue
continue using it until such time as the features added to the 2.x series
attract your interest. We'll continue to answer questions about 1.2.

The target audience for Annotator 2.0 is those who have been frustrated by the
coupling and architecture of 1.2. If any of the following apply to you,
Annotator 2.0 should make you happier:

- You work on an Annotator application that overrides part or all of the
  default user interface.

- You have made substantial modifications to the annotation viewer or editor
  components.

- You use a custom storage plugin.

- You use a custom server-side storage component.

- You integrate Annotator with your own user database.

- You have a custom permissions model for your application.

If you want to know what you'll need to do to upgrade your application or
plugins to work with Annotator 2.0, keep reading.


Upgrading an application
------------------------

The first step to understanding what you need to do to upgrade to 2.0 is to
identify which parts of Annotator 1.2 you use. Review the list below, which
attempts to catalogue Annotator 1.2 patterns and demonstrate the new patterns.


Basic usage
~~~~~~~~~~~

Annotator 1.2 shipped with a jQuery integration, allowing you to write code such
as::

    $('body').annotator();

This has been removed in 2.0. Here's what you'd write now::

    var app = new annotator.App()
    app.include(annotator.ui.main, {element: document.body})
    app.start();

This sets up an Annotator with a user interface. If you decide not to include
the ``annotator.ui.main`` module then your application will not have any of
the familiar user interface components. Instead, you can begin to construct
your own annotation application from those components assembled in a way that
best serves your needs.


Store plugin
~~~~~~~~~~~~

In Annotator 1.2, configuring storage looked like this::

    annotator.addPlugin('Store', {
        prefix: 'http://example.com/api',
        loadFromSearch: {
            uri: window.location.href,
        },
        annotationData: {
            uri: window.location.href,
        }
    });

This code is doing three distinct things:

1. Load the "Store" plugin pointing to an API endpoint at
   ``http://example.com/api``.
2. Make a request to the API with the query ``{uri: window.location.href}``.
3. Add extra data to each created annotation containing the page URL: ``{uri:
   window.location.href}``.

In Annotator 2.0 the configuration of the storage component
(:func:`annotator.storage.http`) is logically separate from a) the loading
of annotations from storage, and b) the extension of annotations with additional
data. An example that replicates the above behavior would look like this
in Annotator 2.0::


    var pageUri = function () {
        return {
            beforeAnnotationCreated: function (ann) {
                ann.uri = window.location.href;
            }
        };
    };

    var app = new annotator.App()
        .include(annotator.ui.main, {element: elem})
        .include(annotator.storage.http, {prefix: 'http://example.com/api'})
        .include(pageUri)

    app.start()
       .then(function () {
           app.annotations.load({uri: window.location.href});
       });

We first create an Annotator extension module that sets the ``uri`` property
property on new annotations. Then we create and configure an
:class:`~annotator.App` that includes the :func:`annotator.storage.http` module.
Lastly, we start the application and load the annotations using the same query
as in the 1.2 example.


Auth plugin
~~~~~~~~~~~

The auth plugin, which in 1.2 retrieved an authentication token from an API
endpoint and set up the Store plugin, is not available for 2.0. See the
documentation for :data:`annotator.storage.HttpStorage.options` for configuring
the request headers directly according to your needs.



Upgrading a plugin
------------------

The first thing to know about Annotator 2.0 is that we are retiring the use of
the word "plugin". Our documentation and code refers to a reusable piece of code
such as :func:`annotator.storage.http` as a :term:`module`. Modules are included
into an :class:`~annotator.App`, and are able to register providers of named
interfaces (such as "storage" or "notifier"), as well as providing runnable
:term:`hook` functions that are called at important moments. The lifecycle
events in Annotator 1.2 (``beforeAnnotationCreated``, ``annotationCreated``,
etc.) are still available as hooks, and it should be reasonably straightforward
to migrate plugins that simply respond to lifecycle events.

The second important observation is that Annotator 2.0 is written in JavaScript,
not CoffeeScript. You may continue to write modules in any dialect you like,
but we hope that this change makes Annotator more accessible to the broader
JavaScript community and encourage you to consider doing the same in order to
promote collaboration.

Lastly, writing an extension module is simpler and more idiomatic than writing a
plugin. Whereas Annotator 1.2 assumed that plugins were "subclasses" of
``Annotator.Plugin``, in Annotator 2.0 a module is a function that returns an
object containing hook functions. It is through these hook functions that
modules provide the bulk of their functionality.

Upgrading a trivial plugin
~~~~~~~~~~~~~~~~~~~~~~~~~~

Here's an Annotator 1.2 plugin that logs to the console when started::

    class Annotator.Plugin.HelloWorld extends Annotator.Plugin
      pluginInit: ->
        console.log("Hello, world!")

Or, in JavaScript::

    Annotator.Plugin.HelloWorld = function HelloWorld() {
        Annotator.Plugin.call(this);
    };
    Annotator.Plugin.HelloWorld.prototype = Object.create(Annotator.Plugin.prototype);
    Annotator.Plugin.HelloWorld.prototype.pluginInit = function pluginInit() {
        console.log("Hello, world!");
    };

Here's the equivalent module for Annotator 2.0::

    function hello() {
        return {
            start: function () {
                console.log("Hello, world!");
            }
        };
    }

For full documentation on writing modules, please see :doc:`module-development`.
