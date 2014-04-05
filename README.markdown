Annotator
=========

[![Build Status](https://secure.travis-ci.org/openannotation/annotator.png)](http://travis-ci.org/openannotation/annotator)
[![Stories in Ready](https://badge.waffle.io/openannotation/annotator.png?label=ready&title=Ready)](https://waffle.io/openannotation/annotator)

Annotator is a web annotation system. Loaded into a webpage, it provides the
user with tools to annotate text (and other elements) in the page. For a simple
demonstration, visit the [demo page][dp] or [download a tagged release of
Annotator][dl] and open `demo.html`.

[dp]: http://annotatorjs.org/demo/
[dl]: https://github.com/openannotation/annotator/downloads

The Annotator project also has a simple but powerful plugin architecture. While
the core annotator code does the bare minimum, it is easily extended with
plugins that perform such tasks as:

- serialization: the `Store` plugin saves all your annotations to a REST API
  backend (see [Storage wiki page][storage] for more and a link to a reference
  implementation)
- authentication and authorization: the `Auth` and `Permissions` plugins allow
  you to decouple the storage of your annotations from the website on which the
  annotation happens. In practice, this means that users could edit pages across
  the web, with all their annotations being saved to one server.
- prettification: the `Markdown` plugin renders all annotation text as
  [Markdown][md]
- tagging: the `Tags` plugin allows you to tag individual annotations

[md]: http://daringfireball.net/projects/markdown/
[storage]: https://github.com/openannotation/annotator/wiki/Storage

Usage
-----

To use Annotator, it's easiest to [download a packaged release][dl]. The most
important files in these packages are `annotator.min.js` (or
`annotator-full.min.js`), which contains the core Annotator code, and
`annotator.min.css`, which contains all the CSS and embedded images for the
annotator.

Annotator requires [jQuery][$]. As of Annotator v1.2.7, jQuery v1.9 is assumed.
If you require an older version of jQuery, or are using an older version of
Annotator and require the new jQuery, you can use the [jQuery Migrate Plugin][$m].
The quickest way to get going with Annotator is to include the following in the
`<head>` of your document (paths relative to the root of the unzipped download):

    <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.9/jquery.min.js'></script>
    <script src='annotator.min.js'></script>
    <link rel='stylesheet' href='annotator.min.css'>
    
Or, with migrate:

    <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'></script>
    <script src= "http://code.jquery.com/jquery-migrate-1.2.1.js"></script>
    <script src='annotator.min.js'></script>
    <link rel='stylesheet' href='annotator.min.css'>

[$]: http://jquery.com/
[$m]: http://plugins.jquery.com/migrate/

You can then initialize Annotator for the whole document by including the
following at the end of the `<body>` tag:

    <script>
      $(document.body).annotator()
    </script>

See `demo.html` for an example how to load and interact with plugins.

Writing Plugins
---------------

As mentioned, Annotator has a simple but powerful plugin architecture. In order
to write your own plugin, you need only add your plugin to the Annotator.Plugin
object, ensuring that the first argument to the constructor is a DOM Element,
and the second is an "options" object. Below is a simple Hello World plugin:

    Annotator.Plugin.HelloWorld = (function() {

      function HelloWorld(element, options) {
        this.element = element;
        this.options = options;
        console.log("Hello World!");
      }

      HelloWorld.prototype.pluginInit = function() {
        console.log("Initialized with annotator: ", this.annotator);
      };

      return HelloWorld;
    })();

Other than the constructor, the only "special" method is `pluginInit`, which is
called after the Annotator has constructed the plugin, and set
`pluginInstance.annotator` to itself. In order to load this plugin into an
existing annotator, you would call `addPlugin("HelloWorld")`. For example:

    $(document.body).annotator()
                    .annotator('addPlugin', 'HelloWorld')

Look at the existing plugins to get a feel for how they work. The Markdown
plugin is a good place to start.

Useful events are triggered on the Annotator `element` (passed to the
constructor of the plugin):

Callback name                                  | Description
---------------------------------------------- | -----------
`annotationsLoaded(annotations)`               | called when annotations are loaded into the DOM. Provides an array of all annotations.
`beforeAnnotationCreated(annotation)`          | called immediately before an annotation is created. If you need to modify the annotation before it is saved to the server by the Store plugin, use this event.
`annotationCreated(annotation)`                | called when the annotation is created. Used by the Store plugin to save new annotations.
`beforeAnnotationUpdated(annotation)`          | as above, but just before an existing annotation is saved.
`annotationUpdated(annotation)`                | as above, but for an existing annotation which has just been edited.
`annotationDeleted(annotation)`                | called when the user deletes an annotation.
`annotationEditorShown(editor, annotation)`    | called when the annotation editor is presented to the user. Allows a plugin to add extra form fields. See the Tags plugin for an example of its use.
`annotationEditorHidden(editor)`               | called when the annotation editor is hidden, both when submitted and when editing is cancelled.
`annotationEditorSubmit(editor, annotation)`   | called when the annotation editor is submitted.
`annotationViewerShown(viewer, annotations)`   | called when the annotation viewer is displayed provides the annotations being displayed
`annotationViewerTextField(field, annotation)` | called when the text field displaying the annotation in the viewer is created

Development
-----------

See [HACKING.markdown](./HACKING.markdown)

Community
---------

The Annotator project has a [mailing list][dev] for developer discussion and
community members can sometimes be found in the `#annotator` channel on
[Freenode IRC][irc].

[dev]: http://lists.okfn.org/mailman/listinfo/annotator-dev
[irc]: http://freenode.net/


