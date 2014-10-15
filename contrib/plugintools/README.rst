Annotator plugin tools
======================

This is a small package for authors of plugins for the Annotator_ library. It
provides a small shim which allows authors to build standalone bundles which
will pull in the Annotator library at runtime rather than when building the
bundle.

To use the package, first include it in your package.json:

    npm install annotator-plugintools --save

You can then get a reference to the Annotator object in your plugins using:

    var Annotator = require('annotator-plugintools').Annotator;

This also gives you access to jQuery, as ``Annotator.Util.$``, and the rest of
the Annotator library, such as ``Annotator.UI``, ``Annotator.Storage``, etc.

You can then build your plugin using browserify:

    browserify myplugin.js > myplugin.bundle.js

The output will be a bundle that can be included in your page after the main
Annotator bundle:

    <script src="annotator.min.js"></script>
    <script src="myplugin.bundle.js"></script>

.. _Annotator: http://annotatorjs.org/
