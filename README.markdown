Annotator
=========

[![Build Status](https://secure.travis-ci.org/openannotation/annotator.svg?branch=master)](http://travis-ci.org/openannotation/annotator)
[![Stories in Ready](https://badge.waffle.io/openannotation/annotator.png?label=ready&title=Ready)](https://waffle.io/openannotation/annotator)

Annotator is a JavaScript library for building annotation systems on the web. It
provides a set of tools to annotate text (and other content) in webpages, and to
save those annotations to a remote storage system. For a simple demonstration,
visit the [demo][demo] or [download a tagged release of Annotator][dl] and open
`demo.html`.

[demo]: http://annotatorjs.org/demo/
[dl]: https://github.com/openannotation/annotator/downloads

Annotator aims to provide a sensible default configuration which allows for
annotations of text in the browser, but it also has a library of plugins, some
in the core, some contributed by third parties, which extend the functionality
of Annotator to provide:

- serialization: "store" plugins save your annotations to a remote server. The
  canonical example is [the `Store` plugin][store] which ships with Annotator.
- authentication and authorization: the [`Auth`][auth] and
  [`Permissions`][perms] plugins allow you to decouple the storage of your
  annotations from the website on which the annotation happens. In practice,
  this means that users could edit pages across the web, with all their
  annotations being saved to one server.
- rendering: the [`Markdown` plugin][markdown] renders annotation bodies as
  [Markdown][md].
- storage of additional data: the [`Tags` plugin][tags] allows you to tag individual
  annotations.

[store]: http://docs.annotatorjs.org/en/latest/plugins/store.html
[auth]: http://docs.annotatorjs.org/en/latest/plugins/auth.html
[perms]: http://docs.annotatorjs.org/en/latest/plugins/permissions.html
[markdown]: http://docs.annotatorjs.org/en/latest/plugins/markdown.html
[md]: http://daringfireball.net/projects/markdown/
[tags]: http://docs.annotatorjs.org/en/latest/plugins/tags.html

For a list of plugins that ship with Annotator, see [the plugin pages of the
Annotator documentation][plugins]. For a list of 3rd party plugins, or to add
your plugin, see [the list of 3rd party plugins on the wiki][3rdparty].

[plugins]: http://docs.annotatorjs.org/en/latest/plugins/index.html
[3rdparty]: https://github.com/openannotation/annotator/wiki#plugins-3rd-party


Usage
-----

See [Getting started with Annotator][gettingstarted].

[gettingstarted][http://docs.annotatorjs.org/en/latest/getting-started.html]


Writing a plugin
----------------

See [Plugin development][plugindev].

[plugindev][http://docs.annotatorjs.org/en/latest/hacking/plugin-development.html]


Development
-----------

See [HACKING.markdown](./HACKING.markdown)


Reporting a bug
---------------

Please report bugs using the [GitHub issue tracker][issues]. Please be sure to
use the search facility to see if anyone else has reported the same bug -- don't
submit duplicates.

Please endeavour to follow [good practice for reporting bugs][bugreport] when
you submit an issue.

Lastly, if you need support or have a question about Annotator, please **do not
use the issue tracker**. Instead, you are encouraged to email the [mailing
list][ml].

[issues]: https://github.com/openannotation/annotator/issues
[bugreport]: http://www.chiark.greenend.org.uk/~sgtatham/bugs.html


Community
---------

The Annotator project has a [mailing list][ml], `annotator-dev`, which you're
encouraged to use for any questions and discussions. We can also be found in the
[`#annotator` channel on Freenode][irc].

[ml]: https://lists.okfn.org/mailman/listinfo/annotator-dev
[irc]: https://webchat.freenode.net/?channels=#annotator


