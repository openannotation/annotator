"use strict";

// In order to build portable extension bundles that can be used with AMD and
// script concatenation plugins are built with this module as 'annotator'.
//
// Annotator will export itself globally when the built UMD modules are used in
// a legacy environment of simple script concatenation.

// Ignore the use of undefined variables
// jshint -W117

var Annotator,
    self;

function exists(x) {
    return (typeof x !== 'undefined' && x !== null);
}

if (!exists(self) && exists(global)) {
    self = global;
}
if (!exists(self) && exists(window)) {
    self = window;
}
// CommonJS/Browserify environment, used while testing. This allows us to `npm
// link` the current development version of Annotator into the
// annotator-plugintools package and have that used by the Karma test runner.
if (exists(self) && exists(require) && !exists(self.define)) {
    Annotator = require('annotator');
}
if (exists(self) && exists(self.Annotator)) {
    Annotator = self.Annotator;
}
// In a pure AMD environment, Annotator may not be exported globally.
if (!exists(Annotator) && exists(self.define) && exists(self.define.amd)) {
    Annotator = self.require('annotator');
}

// If we haven't successfully loaded Annotator by this point, there's no point
// in going on to load the plugin, so throw a fatal error.
if (typeof Annotator !== 'function') {
    throw new Error("Could not find Annotator! In a webpage context, please " +
                    "ensure that the Annotator script tag is loaded before " +
                    "any plugins.");
}


// Note: when working in a CommonJS environment and bundling requirements into
// applications then require calls should refer to modules from the npm lib
// directory of annotator package and avoid this altogether.
exports.Annotator = Annotator;
