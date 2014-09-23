Annotator
=========

|Build Status| |Stories in Ready| |Version on NPM|

::

  ┌──────────────────────────────────────────────────────┐
  │ WARNING! Unstable code in this branch!               │
  ├──────────────────────────────────────────────────────┤
  │ Please be aware that the current stable release of   │
  │ Annotator is v1.2.9 and can be found on the releases │
  │ page (see below) or the v1.2.x branch.               │
  │                                                      │
  │ The code in the master branch is what will become    │
  │ v2.0 in due course, but is likely to have a highly   │
  │ unstable API. You are advised NOT to build on the    │
  │ contents of the master branch at this stage unless   │
  │ you are happy dealing with APIs breaking frequently! │
  └──────────────────────────────────────────────────────┘

Annotator is a JavaScript library for building annotation systems on the web. It
provides a set of tools to annotate text (and other content) in webpages, and to
save those annotations to a remote storage system. For a simple demonstration,
visit the demo_ or download a tagged release of Annotator from `the releases
page`_ and open ``demo.html``.

.. _demo: http://annotatorjs.org/demo
.. _the releases page: https://github.com/openannotation/annotator/releases

Annotator aims to provide a sensible default configuration which allows for
annotations of text in the browser, but it also has a library of plugins, some
in the core, some contributed by third parties, which extend the functionality
of Annotator to provide:

-  serialization: "store" plugins save your annotations to a remote server. The
   canonical example is the |StorePlugin|_ which ships with Annotator.
-  authentication and authorization: the |AuthPlugin|_ and |PermissionsPlugin|_
   allow you to decouple the storage of your annotations from the website on
   which the annotation happens. In practice, this means that users could edit
   pages across the web, with all their annotations being saved to one server.
-  rendering: the |MarkdownPlugin|_ renders annotation bodies as Markdown_.
-  storage of additional data: the |TagsPlugin|_ allows you to tag individual
   annotations.

.. |AuthPlugin| replace:: ``Auth`` plugin
.. _AuthPlugin: http://docs.annotatorjs.org/en/latest/plugins/auth.html
.. |PermissionsPlugin| replace:: ``Permissions`` plugin
.. _PermissionsPlugin: http://docs.annotatorjs.org/en/latest/plugins/permissions.html
.. |MarkdownPlugin| replace:: ``Markdown`` plugin
.. _MarkdownPlugin: http://docs.annotatorjs.org/en/latest/plugins/markdown.html
.. |StorePlugin| replace:: ``Store`` plugin
.. _StorePlugin: http://docs.annotatorjs.org/en/latest/plugins/store.html
.. |TagsPlugin| replace:: ``Tags`` plugin
.. _TagsPlugin: http://docs.annotatorjs.org/en/latest/plugins/tags.html

.. _Markdown: http://daringfireball.net/projects/markdown/

For a list of plugins that ship with Annotator, see the `plugin pages`_ of
the Annotator documentation. For a list of 3rd party plugins, or to add your
plugin, see the `list of 3rd party plugins`_ on the wiki.

.. _plugin pages: http://docs.annotatorjs.org/en/latest/plugins/index.html
.. _list of 3rd party plugins: https://github.com/openannotation/annotator/wiki#plugins-3rd-party


Usage
-----

See `Getting started with Annotator`_.

.. _Getting started with Annotator: http://docs.annotatorjs.org/en/latest/getting-started.html


Writing a plugin
----------------

See `Plugin development`_.

.. _Plugin development: http://docs.annotatorjs.org/en/latest/hacking/plugin-development.html


Development
-----------

See `HACKING.rst <./HACKING.rst>`__.


Reporting a bug
---------------

Please report bugs using the `GitHub issue tracker`_. Please be sure to use the
search facility to see if anyone else has reported the same bug -- don't submit
duplicates.

Please endeavour to follow `good practice for reporting bugs`_ when you submit
an issue.

Lastly, if you need support or have a question about Annotator, please **do not
use the issue tracker**. Instead, you are encouraged to email the `mailing
list`_.

.. _GitHub issue tracker: https://github.com/openannotation/annotator/issues
.. _good practice for reporting bugs: http://www.chiark.greenend.org.uk/~sgtatham/bugs.html


Community
---------

The Annotator project has a `mailing list`_, ``annotator-dev``, which you're
encouraged to use for any questions and discussions. We can also be found in
|IRC|_.

.. _mailing list: https://lists.okfn.org/mailman/listinfo/annotator-dev
.. |IRC| replace:: the ``#annotator`` channel on Freenode
.. _IRC: https://webchat.freenode.net/?channels=#annotator


.. |Build Status| image:: https://secure.travis-ci.org/openannotation/annotator.svg?branch=master
   :target: http://travis-ci.org/openannotation/annotator
.. |Stories in Ready| image:: https://badge.waffle.io/openannotation/annotator.png?label=ready&title=Ready
   :target: https://waffle.io/openannotation/annotator
.. |Version on NPM| image:: http://img.shields.io/npm/v/annotator.svg
   :target: https://www.npmjs.org/package/annotator
