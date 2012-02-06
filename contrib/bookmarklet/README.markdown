Annotator Bookmarklet
=====================

A Javascript bookmarklet wrapper around the Annotator plugin. This allows the
user to load the annotator into any web page and post the annotations to a
server (by default this is [AnnotateIt][#annotateit]).

The bookmarklet version of the annotator has the following plugins loaded:

 - [Auth][#wiki-auth]: authenticates with [AnnotateIt][#annotateit]
 - [Store][#wiki-store]: saves to [AnnotateIt][#annotateit]
 - [Permissions][#wiki-permissions]
 - [Unsupported][#wiki-unsupported]: displays a notification if the bookmarklet is run on an
   unsupported browser

and optionally, the [Tags plugin][#wiki-tags].

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

Configuration
-------------

In order to configure the bookmarklet for your needs it accepts `config` hash of
options. These are set in the _config.json_ file. There's an example in the
repository (see _config.example.json_). The options are as follows:

### externals

 - `jQuery`: A URL to a hosted version of jQuery. This will default to the latest
    minor version of 1.7 hosted on Google's CDN.
 - `source`: The generated Annotator Javascript source code (see Development)
 - `styles`: The generated Annotator CSS source code (see Development)
   
### auth

Settings for the [Auth plugin][#wiki-auth]

- `tokenUrl`: The URL of the auth token generator to use (default: http://annotateit.org/api/token)

### store

Settings for the [Store plugin][#wiki-store].

 - `prefix`: The prefix URL for the store (default: http://annotateit.org/api)

### permissions

Settings for the [Permissions plugin][#wiki-permissions].

#### tags

If this is set to `true` the [Tags plugin][#wiki-tags] will be loaded.

Development
-----------

To build a copy of the bookmarklet run:

    $ cake bookmarklet:package

This will minify the source of _bookmarklet.js_ and embed it within _dev.html_
replacing the `{bookmarklet}` token. The file will be written to _demo.html_.

All dependencies will be packaged into the _/pkg_ directory. These include
_annotator.min.css_ and _annotator.min.js_.

To continuously rebuild the bookmarklet each time the _bookmarklet.js_ changes
run:

    $ cake bookmarklet:watch

[#annotateit]: http://annotateit.org
[#wiki-auth]: https://github.com/okfn/annotator/wiki/Auth-Plugin
[#wiki-permissions]: https://github.com/okfn/annotator/wiki/Permissions-Plugin
[#wiki-store]: https://github.com/okfn/annotator/wiki/Store-Plugin
[#wiki-tags]: https://github.com/okfn/annotator/wiki/Tags-Plugin
[#wiki-tags]: https://github.com/okfn/annotator/wiki/Unsupported-Plugin
[#homebrew]: http://mxcl.github.com/homebrew/
[#yui-source]: https://github.com/mxcl/homebrew/blob/master/Library/Formula/yuicompressor.rb
