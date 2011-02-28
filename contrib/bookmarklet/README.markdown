Annotator Bookmarklet
=====================

A JavaScript bookmarklet wrapper around the Annotator plugin. This allows the
user to load the annotator into any web page and post the annotations to a
server (by default this is [annotateit.org][#annotateit]).

The bookmarklet version of the annotator has the following plugins loaded:

 - Permissions: Only current user has read/write/delete/admin access.
 - Store: Posts to [annotateit.org][#annotateit] and saves the current page uri
   with the annotation
 - Unsupported: Displays a notification if the bookmarklet is run on an
   unsupported browser.

Development
-----------

To build a copy of the bookmarklet run:

    $ cake bookmarklet:build

This will minify the source of _bookmarklet.js_ and embed it within _dev.html_
replacing the `{bookmarklet}` token. The file will be written to _demo.html_.

All dependancies will be packaged into the _/pkg_ directory. These include
_annotator.min.css_ and _annotator.min.js_. The hosted location of these files
can be set by the `domain` property in _bookmarklet.js_

To continuously rebuild the bookmarklet each time the _bookmarklet.js_ changes
run:

    $ cake bookmarklet:watch

[#annotateit]: http://annotateit.org
