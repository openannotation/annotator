"use strict";

// Inject Annotator CSS
var insertCss = require('insert-css');
var css = require('./css/annotator.css');
insertCss(css);

var app = require('./src/app');
var storage = require('./src/storage');
var ui = require('./src/ui');
var util = require('./src/util');

// Core annotator components
exports.App = app.App;

// Access to libraries (for browser installations)
exports.storage = storage;
exports.ui = ui;
exports.util = util;

// Ext namespace (for core-provided extension modules)
exports.ext = {};

var g = util.getGlobal();

// If wicked-good-xpath is available, install it. This will not overwrite any
// native XPath functionality.
var wgxpath = g.wgxpath;
if (typeof wgxpath !== "undefined" &&
    wgxpath !== null &&
    typeof wgxpath.install === "function") {
    wgxpath.install();
}

// Store a reference to the current annotator object, if one exists.
var _annotator = g.annotator;

// Restores the Annotator property on the global object to it's
// previous value and returns the Annotator.
exports.noConflict = function noConflict() {
    g.annotator = _annotator;
    return this;
};
