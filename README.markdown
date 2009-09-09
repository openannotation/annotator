JS Annotate
===========

A wee playground to see what can be done with a Javascript annotation system.

Usage
-----

To use the annotator, you'll probably want to set up some kind of back end 
that can save and load your annotations to a database. An example of a page 
that talks to such a backend might look like:

    <html>
      <head>
        <link rel="stylesheet" src="jsannotator.min.css">
        <script src="jsannotator.min.js"></script>
      </head>
      <body>
        <p>Lorem ipsum dolor sit .....</p>

        <button id="load">Load annotations</button>
        <button id="save">Save annotations!</button>

        <script>
          jQuery(document).ready(function($) {
            $('p').annotator();

            $('button#load').click(function () {
              $.getJSON('/resource/annotations', function (data) {
                $('p').annotator('loadAnnotations', data);
              });
            });

            $('button#save').click(function () {
              $.post('/resource/annotations', $('p').data('annotator').dumpAnnotations());
            });
          });
        </script>
      </body>
    </html>

This is obviously a very basic example, with no error checking/handling, but 
it gets the idea across. The Annotator dumpAnnotations/loadAnnotations methods 
return/accept native javascript objects, not JSON strings, and this is 
reflected above.

Development
-----------

The specs/tests can be found in spec/, and are most easily run by opening 
spec/spec.dom.html in a browser.

Annotation format
-----------------

The annotator stores annotations internally as objects like the following.

    { id: 1,
      text: "My annotation",
      ranges: [
        { uri: "http://www.example.com/my/resource/identifier",
          start: "/html/body/div/p[2]",
          startOffset: 32,
          end: "/html/body/div/p[3]",
          endOffset: 47
        },
        { uri: "http://...", ... } 
      ]
    }

Note that an annotation can be associated with multiple ranges, over multiple 
documents. You can call `#loadAnnotations(array)` on an instantiated annotator 
and the annotations will be added to the page. Likewise, you can dump all the 
current annotations in the page with `#dumpAnnotations()`. This will return an 
array of annotation objects (as above) which can then be serialized to JSON.

