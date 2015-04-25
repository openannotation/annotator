Hacking on Annotator
====================

If you wish to develop Annotator, you'll need to have a working installation of
`Node.js <http://nodejs.org/>`__ (>= v0.10.x). Once installed (on most systems
Node comes bundled with `NPM <http://npmjs.org/>`__) you should run the
following to install Annotator's development dependencies::

    $ npm install .

The Annotator source is found in ``src/``. You can use the ``tools/serve``
script while developing to serve bundle the source files. ``dev.html`` can be useful
when developing.

The tests can be found in ``test/`` and can be run with::

    $ npm test


Build
-----

Building the packaged version of Annotator involves running the appropriate
``make`` task. To build everything, run::

    $ make

To build just the main Annotator bundle, run::

    $ make pkg/annotator.min.js

To build a standalone extension module, run::

    $ make pkg/annotator.document.min.js
