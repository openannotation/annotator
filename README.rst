Annotator
=========

|Build Status| |Version on NPM| |IRC Channel|

|Build Matrix|

Annotator is a JavaScript library for building annotation applications in
browsers. It provides a set of interoperable tools for annotating content in
webpages. For a simple demonstration, visit the `Annotator home page`_ or
download a tagged release of Annotator from `the releases page`_ and open
``demo.html``.

.. _Annotator home page: http://annotatorjs.org/
.. _the releases page: https://github.com/openannotation/annotator/releases

Components within Annotator provide:

-  user interface: components to create, edit, and display annotations in a
   browser.
-  persistence: storage components help you save your annotations to a remote
   server.
-  authorization and identity: integrate Annotator with your application's login
   and permissions systems.
-  rich metadata: the |documentmodule|_ sniffs the page on which annotations
   are being made for document metadata (such as that provided by `Dublin Core
   tags`_ or the `Facebook Open Graph`_) that allows you to enrich the
   presentation of these annotations.

.. _Dublin Core tags: http://dublincore.org/
.. _Facebook Open Graph: https://developers.facebook.com/docs/opengraph
.. |documentmodule| replace:: ``annotator.ext.document`` module
.. _documentmodule: http://docs.annotatorjs.org/en/latest/modules/document.html


Usage
-----

See Installing_ and `Configuring and using Annotator`_ from the documentation_.

.. _Installing: http://docs.annotatorjs.org/en/latest/installing.html
.. _Configuring and using Annotator: http://docs.annotatorjs.org/en/latest/usage.html
.. _documentation: http://docs.annotatorjs.org/en/latest/


Writing a module
----------------

See `Module development`_.

.. _Module development: http://docs.annotatorjs.org/en/latest/module-development.html


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
.. |IRC Channel| image:: https://img.shields.io/badge/IRC-%23annotator-blue.svg
   :target: https://www.irccloud.com/invite?channel=%23annotator&amp;hostname=irc.freenode.net&amp;port=6697&amp;ssl=1
   :alt: #hypothes.is IRC channel
