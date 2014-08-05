Plugin development
==================

Getting Started
---------------

Building a plugin is very simple. Simply attach a function that creates
your plugin to the ``Annotator.Plugin`` namespace. The function will
receive the following arguments.

``element``
    The DOM element that is currently being annotated.

Additional arguments (such as options) can be passed in by the user when
the plugin is added to the Annotator. These will be passed in after the
``element``.

.. code:: javascript

      Annotator.Plugin.HelloWorld = function (element) {
        var myPlugin = {};
        // Create your plugin here. Then return it.
        return myPlugin;
      };

Using Your Plugin
~~~~~~~~~~~~~~~~~

Adding your plugin to the annotator is the same as for all supported
plugins. Simply call "addPlugin" on the annotator and pass in the name
of the plugin and any options. For example:

.. code:: javascript

      // Setup the annotator on the page.
      var content = $('#content').annotator();

      // Add your plugin.
      content.annotator('addPlugin', 'HelloWorld' /*, any other options */);

Setup
~~~~~

When the annotator creates your plugin it will take the following steps.

1. Call your Plugin function passing in the annotated element plus any
   additional arguments. (The Annotator calls the function with ``new``
   allowing you to use a constructor function if you wish).
2. Attaches the current instance of the Annotator to the ``.annotator``
   property of the plugin.
3. Calls ``.pluginInit()`` if the method exists on your plugin.

pluginInit()
~~~~~~~~~~~~

If your plugin has a ``pluginInit()`` method it will be called after the
annotator has been attached to your plugin. You can use it to set up the
plugin.

In this example we add a field to the viewer that contains the text
provided when the plugin was added.

.. code:: javascript

      Annotator.Plugin.Message = function (element, message) {
        var plugin = {};

        plugin.pluginInit = function () {
            this.annotator.viewer.addField({
              load: function (field, annotation) {
                field.innerHTML = message;
              }
            })
        };

        return plugin;
      }

Usage:

.. code:: javascript

      // Setup the annotator on the page.
      var content = $('#content').annotator();

      // Add your plugin to the annotator and display the message "Hello World"
      // in the viewer.
      content.annotator('addPlugin', 'Message', 'Hello World');

Extending Annotator.Plugin
--------------------------

All supported Annotator plugins use a base "class" that has some useful
features such as event handling. To use this you simply need to extend
the ``Annotator.Plugin`` function.

.. code:: javascript

      // This is now a constructor and needs to be called with `new`.
      Annotator.Plugin.MyPlugin = function (element, options) {

        // Call the Annotator.Plugin constructor this sets up the .element and
        // .options properties.
        Annotator.Plugin.apply(this, arguments);

        // Set up the rest of your plugin.
      };

      // Set the plugin prototype. This gives us all of the Annotator.Plugin methods.
      Annotator.Plugin.MyPlugin.prototype = new Annotator.Plugin();

      // Now add your own custom methods.
      Annotator.Plugin.MyPlugin.prototype.pluginInit = function () {
        // Do something here.
      };

If you're using jQuery you can make this process a lot neater.

.. code:: javascript

    Annotator.Plugin.MyPlugin = function (element, options) {
      // Same as before.
    };

    jQuery.extend(Annotator.Plugin.MyPlugin.prototype, new Annotator.Plugin(), {
      events: {},
      options: {
        // Any default options.
      }
      pluginInit: function () {

      },
      myCustomMethod: function () {

      }
    });

Annotator.Plugin API
--------------------

The Annotator.Plugin provides the following methods and properties.

element
~~~~~~~

This is the DOM element currently being annotated wrapped in a jQuery
wrapper.

options
~~~~~~~

This is the options object, you can set default options when you create
the object and they will be overridden by those provided when the plugin
is created.

events
~~~~~~

These can be either DOM events to be listened for within the
``.element`` or custom events defined by you. Custom events will not
receive the ``event`` property that is passed to DOM event listeners.
These are bound when the plugin is instantiated.

publish(name, parameters)
~~~~~~~~~~~~~~~~~~~~~~~~~

Publish a custom event to all subscribers.

-  ``name``: The event name.
-  ``parameters``: An array of parameters to pass to the subscriber.

subscribe(name, callback)
~~~~~~~~~~~~~~~~~~~~~~~~~

Subscribe to a custom event. This can be used to subscribe to your own
events or those broadcast by the annotator and other plugins.

-  ``name``: The event name.
-  ``callback``: A callback to be fired when the event is published. The
   callback will receive any arguments sent when the event is published.

unsubscribe(name, callback)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Unsubscribe from an event.

-  ``name``: The event name.
-  ``callback``: The callback to be unsubscribed.

Annotator Events
----------------

The annotator fires the following events at key points in its operation.
You can subscribe to them using the ``.subscribe()`` method. This can be
called on either the ``.annotator`` object or if you're extending
``Annotator.Plugin`` the plugin instance itself. The events are as
follows:

``beforeAnnotationCreated(annotation)``
    called immediately before an annotation is created. If you need to modify
    the annotation before it is saved use this event.
``annotationCreated(annotation)``
    called when the annotation is created use this to store the annotations.
``beforeAnnotationUpdated(annotation)``
    as above, but just before an existing annotation is saved.
``annotationUpdated(annotation)``
    as above, but for an existing annotation which has just been edited.
``annotationDeleted(annotation)``
    called when the user deletes an annotation.
``annotationEditorShown(editor, annotation)``
    called when the annotation editor is presented to the user.
``annotationEditorHidden(editor)``
    called when the annotation editor is hidden, both when submitted and when
    editing is cancelled.
``annotationEditorSubmit(editor, annotation)``
    called when the annotation editor is submitted.
``annotationViewerShown(viewer, annotations)``
    called when the annotation viewer is shown and provides the annotations
    being displayed.
``annotationViewerTextField(field, annotation)``
    called when the text field displaying the annotation comment in the viewer
    is created.

Example
~~~~~~~

A plugin that logs annotation activity to the console.

.. code:: javascript

      Annotator.Plugin.StoreLogger = function (element) {
        return {
          pluginInit: function () {
            this.annotator
                .subscribe("annotationCreated", function (annotation) {
                  console.info("The annotation: %o has just been created!", annotation)
                })
                .subscribe("annotationUpdated", function (annotation) {
                  console.info("The annotation: %o has just been updated!", annotation)
                })
                .subscribe("annotationDeleted", function (annotation) {
                  console.info("The annotation: %o has just been deleted!", annotation)
                });
          }
        }
      };
