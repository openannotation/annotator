JS Annotate
===========

A wee playground to see what can be done with a Javascript annotation system.

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

