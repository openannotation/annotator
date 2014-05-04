Hacking on Annotator
====================

Quick setup for lazy people (on a Mac)
--------------------------------------

::

    $ ./tools/setup

Slower introduction for industrious people (and those on Linux/Windows)
-----------------------------------------------------------------------

If you wish to develop Annotator, you'll need to have a working
installation of `Node.js <http://nodejs.org/>`__ (v0.8.x). Once
installed (on most systems Node comes bundled with
`NPM <http://npmjs.org/>`__) you should run the following to install
Annotator's development dependencies::

    $ npm install .

The Annotator source is found in ``src/``, and is written in
CoffeeScript, which is a little language that compiles to Javascript.
See the `CoffeeScript website <http://coffeescript.org/>`__ for more
information.

``dev.html`` loads the raw development files from ``lib/`` and can be
useful when developing.

The tests can be found in ``test/spec/``. You can run the tests in your
browser (using ``test/runner.html``), but while you're working it's
probably easiest to run the tests using ``npm test`` from the root of
the repository. This will require
`PhantomJS <http://www.phantomjs.org/>`__ and the mocha runner::

    $ npm install -g phantomjs mocha-phantomjs

For inline documentation we use `TomDoc <http://tomdoc.org/>`__. It's a
Ruby specification but it also works nicely with CoffeeScript.

Tools
-----

There are a number of useful development tools shipped in the ``tools/``
directory::

    $ ./tools/build      # compiles src/*.coffee and test/*.coffee into lib/*.js
    $ ./tools/watch      # like the above, but automatically recompiles files when they change
    $ ./tools/test       # runs the test suite with PhantomJS

Building the packaged version of Annotator involves running the
appropriate ``make`` task. For example::

    $ make                     # build everything
    $ make bookmarklet         # build the bookmarklet
    $ make annotator plugins   # build annotator and individual plugin files.

