"use strict";

// Inject Annotator CSS
var insertCss = require('insert-css');
var css = require('./css/annotator.css');
insertCss(css);

var app = require('./src/app');
var util = require('./src/util');

// Core annotator components
exports.App = app.App;

// Access to libraries (for browser installations)
exports.authz = require('./src/authz');
exports.identity = require('./src/identity');
exports.notification = require('./src/notification');
exports.storage = require('./src/storage');
exports.ui = require('./src/ui');
exports.util = util;

// Ext namespace (for core-provided extension modules)
exports.ext = {};

// If wicked-good-xpath is available, install it. This will not overwrite any
// native XPath functionality.
var wgxpath = global.wgxpath;
if (typeof wgxpath !== "undefined" &&
    wgxpath !== null &&
    typeof wgxpath.install === "function") {
    wgxpath.install();
}

// Store a reference to the current annotator object, if one exists.
var _annotator = global.annotator;

// Restores the Annotator property on the global object to it's
// previous value and returns the Annotator.
exports.noConflict = function noConflict() {
    global.annotator = _annotator;
    return this;
};
