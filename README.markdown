Annotator
=========

Annotator is a web annotation system. Loaded into a webpage, it provides the user with tools to annotate text (and other elements) in the page. For a simple demonstration, visit the [demo page][dp] or [download a tagged release of Annotator][dl] and open `demo.html`.

[dp]: http://okfn.github.com/annotator/demo/
[dl]: https://github.com/okfn/annotator/downloads

The Annotator project also has a simple but powerful plugin architecture. While the core annotator code does the bare minimum, it is easily extended with plugins that perform such tasks as:

- serialization: the `Store` plugin saves all your annotations to a REST API backend (see [Storage wiki page][storage] for more and a link to a reference implementation)
- authentication and authorization: the `Auth` and `Permissions` plugins allow you to decouple the storage of your annotations from the website on which the annotation happens. In practice, this means that users could edit pages across the web, with all their annotations being saved to one server.
- prettification: the `Markdown` plugin renders all annotation text as [Markdown][md]
- tagging: the `Tags` plugin allows you to tag individual annotations

[md]: http://daringfireball.net/projects/markdown/
[storage]: https://github.com/okfn/annotator/wiki/Storage

Usage
-----

To use Annotator, it's easiest to [download a packaged release][dl].

In a tagged release, the `pkg/` directory will contain all the files you need to get going. The most important are `annotator.min.js`, which contains the core Annotator code, and `annotator.min.css`, which contains all the CSS and embedded images for the annotator.

Annotator requires [jQuery][$] and [an implementation][json2] of `JSON.parse` and `JSON.stringify`. In short, the quickest way to get going with annotator is to include the following in the `<head>` of your document (paths relative to the repository root):

    <script src='lib/vendor/jquery.js'></script>
    <script src='lib/vendor/json2.js'></script>

    <script src='pkg/annotator.min.js'></script>
    <link rel='stylesheet' href='pkg/annotator.min.css'>

[$]: http://jquery.com/
[json2]: https://github.com/douglascrockford/JSON-js/blob/master/json2.js

You can then initialize Annotator for the whole document by including the following at the end of the `<body>` tag:

    <script>
      $(document.body).annotator()
    </script>

See `demo.html` for an example how to load and interact with plugins.

Writing Plugins
---------------

As mentioned, Annotator has a simple but powerful plugin architecture. In order to write your own plugin, you need only add your plugin to the Annotator.Plugin object, ensuring that the first argument to the constructor is a DOM Element, and the second is an "options" object. Below is a simple Hello World plugin:

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

Other than the constructor, the only "special" method is `pluginInit`, which is called after the Annotator has constructed the plugin, and set `pluginInstance.annotator` to itself. In order to load this plugin into an existing annotator, you would call `addPlugin("HelloWorld")`. For example:

    $(document.body).annotator()
                    .annotator('addPlugin', 'HelloWorld')

Look at the existing plugins to get a feel for how they work. The Markdown plugin is a good place to start.

Useful events are triggered on the Annotator `element` (passed to the constructor of the plugin):

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

If you wish to develop Annotator, you'll need to have a working installation of [Node.js][node] (v0.6.x). I'd highly recommend installing both Node.js and the [Node Package Manager][npm], after which you can run the following to get up and running:

    $ npm install .

The Annotator source is found in `src/`, and is written in CoffeeScript, which is a little language that compiles to Javascript. See the [CoffeeScript website][coffee] for more information.

`dev.html` loads the raw development files from `lib/` and can be useful when developing.

The tests are to be found in `test/spec/`, and use [Jasmine][jas] to support a BDD process.

For inline documentation we use [TomDoc][tom]. It's a Ruby specification but it
also works nicely with CoffeeScript.


The `Cakefile` provides a number of useful tasks. (**NB**: If `cake` doesn't work for you, try `` `npm bin`/cake`` instead.)

    $ cake serve        # serves the directory at http://localhost:8000 (requires python)
    $ cake test         # opens the test suite in your browser
    $ cake test:phantom # runs the test suite with PhantomJS
    $ cake watch        # compiles src/*.coffee files into lib/*.js when they change
    $ cake package[:*]  # builds the production version of Annotator in pkg/

Run `cake` (or `` `npm bin`/cake``) to see the list of all available tasks.

Community
---------

The annotator project has a [mailing list][dev] for developer discussion and community members can sometimes be found in the #annotator channel on [freenode IRC][irc].

[node]: http://nodejs.org/
[npm]: http://npmjs.org/
[coffee]: http://coffeescript.org/ 
[jas]: http://pivotal.github.com/jasmine/
[tom]: http://tomdoc.org/
[dev]: http://lists.okfn.org/mailman/listinfo/annotator-dev
[irc]: http://freenode.net/


