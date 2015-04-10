"use strict";

// Inject Annotator CSS
var insertCss = require('insert-css');
var css = require('./css/annotator.css');
insertCss(css);

var annotator = require('./src/annotator');
var ui = require('./src/ui');
var storage = require('./src/storage');
var util = require('./src/util');

// Core annotator components
exports.Annotator = annotator.Annotator;
exports.supported = annotator.supported;

// Access to libraries (for browser installations)
exports.storage = storage;
exports.ui = ui;
exports.util = util;

// Plugin namespace (for core-provided plugins)
exports.plugin = {};

// Store a reference to the current annotator object, if one exists.
var g = util.getGlobal();
var _annotator = g.annotator;

// Restores the Annotator property on the global object to it's
// previous value and returns the Annotator.
exports.noConflict = function noConflict() {
    g.annotator = _annotator;
    return this;
};
