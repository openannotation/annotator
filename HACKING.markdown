Hacking on Annotator
====================

Quick setup for lazy people (on a Mac)
--------------------------------------

    $ ./tools/setup

Slower introduction for industrious people (and those on Linux/Windows)
-----------------------------------------------------------------------

If you wish to develop Annotator, you'll need to have a working installation of [Node.js][node] (v0.6.x). Once installed (on most systems Node comes bundled with [NPM][npm]) you should run the following to install Annotator's development dependencies.

    $ npm install .

The Annotator source is found in `src/`, and is written in CoffeeScript, which is a little language that compiles to Javascript. See the [CoffeeScript website][coffee] for more information.

`dev.html` loads the raw development files from `lib/` and can be useful when developing.

The tests are to be found in `test/spec/`, and use [Jasmine][jas] to support a BDD process. You can either run the tests in your browser (using `test/runner.html`) or using a [PhantomJS][phantom] console runner (see below).

For inline documentation we use [TomDoc][tom]. It's a Ruby specification but it
also works nicely with CoffeeScript.

Tools
-----

There are a number of useful development tools shipped in the `tools/` directory.
 
    $ ./tools/watch          # compiles src/*.coffee files into lib/*.js when they change
    $ ./tools/test_phantom   # runs the test suite with PhantomJS (requires Python and PhantomJS)

Building the packaged version of Annotator requires Avery Pennarun's excellent [redo build tool][redo]. Instructions on installing redo can be found below:

    $ redo                   # just build everything
    $ redo help              # show available build tasks

If you really can't be bothered to install `redo` (you should: it's awesome) you can just run the included minimal `do` script:

    $ ./tools/do


Installing `redo`
-----------------

### On a Mac

    $ brew install redo

### On *nix

    $ git clone git://github.com/apenwarr/redo.git
    $ cd redo && make install

[coffee]: http://coffeescript.org/ 
[homebrew]: http://mxcl.github.com/homebrew/
[jas]: http://pivotal.github.com/jasmine/
[node]: http://nodejs.org/
[npm]: http://npmjs.org/
[phantom]: http://www.phantomjs.org/
[redo]: https://github.com/apenwarr/redo
[tom]: http://tomdoc.org/
