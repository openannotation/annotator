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

Generation
----------

To generate the bookmarklet source code simply run:

    $ cake bookmarklet:build

This will output the source to the console. To save the code to a file you could
run the following:

    $ cake bookmarklet:build > bookmarklet.js

NOTE: Building the bookmarklet currently requires a `yuicompressor` executable.
If you're running a Mac with [Homebrew][#homebrew] installed you can simply run.
Or create a [similar executable yourself][#yui-source].

    $ brew install yuicompressor

TODO: The Cakefile needs to be updated to remove this requirement.

Configuration
-------------

In order to configure the bookmarklet for your needs it accepts `config` hash of
options. These are set in the _config.json_ file. There's an example in the
repository (see _config.example.json_). The options are as follows:

### externals

 - `jQuery`: A URL to a hosted version of jQuery. This will default to version
    1.5.1 hosted on Googles CDN.
 - `source`: The generated Annotator JavaScript source code (see Development)
 - `styles`: The generated Annotator CSS source code (see Development)
   
### auth

Currently only supports custom headers to be provided when querying the store.

 - `headers`: An object literal of custom headers.

### store

Settings for the [Store plugin][#wiki-store].

 - `prefix`: The prefix url for the store.

### permissions

Settings for the [Permissions plugin][#wiki-permissions].

 - `user`: The object representing the current user.
 - `permissions`: An object literal of permissions to set on annotations.

Development
-----------

To build a copy of the bookmarklet run:

    $ cake bookmarklet:package

This will minify the source of _bookmarklet.js_ and embed it within _dev.html_
replacing the `{bookmarklet}` token. The file will be written to _demo.html_.

All dependancies will be packaged into the _/pkg_ directory. These include
_annotator.min.css_ and _annotator.min.js_. The hosted location of these files
can be set by the `domain` property in _bookmarklet.js_

To continuously rebuild the bookmarklet each time the _bookmarklet.js_ changes
run:

    $ cake bookmarklet:watch

[#annotateit]: http://annotateit.org
[#wiki-permissions]: https://github.com/okfn/annotator/wiki/Permissions-Plugin
[#wiki-store]: https://github.com/okfn/annotator/wiki/Store-Plugin
[#homebrew]: http://mxcl.github.com/homebrew/
[#yui-source]: https://github.com/mxcl/homebrew/blob/master/Library/Formula/yuicompressor.rb
