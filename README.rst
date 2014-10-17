Annotator
=========

|Build Status| |Version on NPM|

|Build Matrix|

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
visit the `Annotator home page`_ or download a tagged release of Annotator from
`the releases page`_ and open ``demo.html``.

.. _Annotator home page: http://annotatorjs.org/
.. _the releases page: https://github.com/openannotation/annotator/releases

Annotator aims to provide a sensible default configuration which allows for
annotations of text in the browser, but it can also be extended in order to
provide:

-  persistence: storage components help you save your annotations to a remote
   server. One notable example is the |HTTPStorageComponent|_ which ships with
   Annotator and talks to the |AnnotatorStore|_.
-  rich metadata: the |DocumentPlugin|_ sniffs the page on which annotations are
   being made for document metadata (such as that provided by `Dublin Core
   tags`_ or the `Facebook Open Graph`_) that allows you to enrich the
   presentation of these annotations.
-  authentication and authorization: the |AuthComponent|_ allows you to restrict
   the creation of annotations to logged in users, while the
   |PermissionsComponent|_ allow you fine-grained control over who has
   permission to create and update annotations.

.. |HTTPStorageComponent| replace:: ``HTTPStorage`` component
.. _HTTPStorageComponent: http://docs.annotatorjs.org/en/latest/storage/http.html
.. |AnnotatorStore| replace:: ``annotator-store`` API
.. _AnnotatorStore: https://github.com/openannotation/annotator-store/
.. _Dublin Core tags: http://dublincore.org/
.. _Facebook Open Graph: https://developers.facebook.com/docs/opengraph
.. |AuthComponent| replace:: ``Auth`` component
.. _AuthComponent: http://docs.annotatorjs.org/en/latest/storage/auth.html
.. |PermissionsComponent| replace:: ``Permissions`` component
.. _PermissionsComponent: http://docs.annotatorjs.org/en/latest/permissions.html

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
encouraged to use for any questions and discussions. It is archived for easy
browsing and search at `gmane.comp.web.annotator`_. We can also be found in
|IRC|_.

.. _mailing list: https://lists.okfn.org/mailman/listinfo/annotator-dev
.. _gmane.comp.web.annotator: http://dir.gmane.org/gmane.comp.web.annotator
.. |IRC| replace:: the ``#annotator`` channel on Freenode
.. _IRC: https://webchat.freenode.net/?channels=#annotator


.. |Build Status| image:: https://secure.travis-ci.org/openannotation/annotator.svg?branch=master
   :target: http://travis-ci.org/openannotation/annotator
.. |Version on NPM| image:: http://img.shields.io/npm/v/annotator.svg
   :target: https://www.npmjs.org/package/annotator
.. |Build Matrix| image:: https://saucelabs.com/browser-matrix/hypothesisannotator.svg
   :target: https://saucelabs.com/u/hypothesisannotator
