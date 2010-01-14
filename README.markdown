Annotator
=========

A wee playground to see what can be done with a Javascript annotation system. 
You should be able to create an Annotator on an element (or the whole page) as 
simply as $('#content').annotator().

Separately from the annotator (which will simply create annotations in the 
page and allow you to read their contents) you can also create an 
AnnotationStore which will listen to the Annotator and will save/restore your 
annotations across page loads via a RESTful HTTP interface.

Usage
-----

To use the annotator, it's easiest to download a tagged release of the annotator from http://github.com/nickstenning/annotator/downloads. You need to make the contents of the pkg/ directory available from the web and include the Javascript and CSS files as below.

(NB: the pkg/ directory will be empty unless you've downloaded a tagged release as suggested.)

You'll probably also want to set up some kind of back end that can save and
load your annotations to a database. An example of a page that talks to such a
backend might look like:

    <html>
      <head>
        <link rel="stylesheet" src="jsannotator.min.css">
        <script src="jsannotator.min.js"></script>
      </head>
      <body>
        <p>Lorem ipsum dolor sit .....</p>

        <script>
          jQuery(function($) {
            $('p').annotationStore();
          });
        </script>
      </body>
    </html>

An example Sinatra backend (which doesn't actually save the annotations to 
disk) can be found in examples/.

Development
-----------

The specs can be found in spec/, and are most easily run by opening 
spec/spec.dom.html in a browser.

Annotation format
-----------------

The annotator stores annotations internally as objects like the following.

    { id: 1,
      text: "My annotation",
      ranges: [
        { start: "/html/body/div/p[2]",
          startOffset: 32,
          end: "/html/body/div/p[3]",
          endOffset: 47
        },
        { start: "/html/...", ... } 
      ]
    }

Note that an annotation can in theory be associated with multiple ranges, i.e. 
one object will create multiple distinct highlighted areas. Multi-range 
selection *is* possible in some browsers (try holding down Ctrl or Cmd), and 
should 'just work'. If it doesn't work for you I'd be interested in hearing 
about that.

You can call `#loadAnnotations(array)` on an instantiated annotator and the 
annotations will be added to the page. 
