"use strict";

var $ = require('jquery');
var Promise = require('es6-promise').Promise;

var ESCAPE_MAP = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
    "/": "&#47;"
};


// escapeHtml sanitizes special characters in text that could be interpreted as
// HTML.
function escapeHtml(string) {
    return String(string).replace(/[&<>"'\/]/g, function (c) {
        return ESCAPE_MAP[c];
    });
}


// getGlobal returns the global object (window in a browser, the global
// namespace object in Node, etc.)
function getGlobal() {
    // jshint -W054
    return new Function('return this')();
    // jshint +W054
}


// I18N
var gettext = (function () {
    var g = getGlobal();

    if (typeof g.Gettext === 'function') {
        var _gettext = new g.Gettext({domain: "annotator"});
        return function (msgid) { return _gettext.gettext(msgid); };
    }

    return function (msgid) { return msgid; };
}());


// Returns the absolute position of the mouse relative to the top-left rendered
// corner of the page (taking into account padding/margin/border on the body
// element as necessary).
function mousePosition(event) {
    var body = getGlobal().document.body;
    var offset = {top: 0, left: 0};

    if ($(body).css('position') !== "static") {
        offset = $(body).offset();
    }

    return {
        top: event.pageY - offset.top,
        left: event.pageX - offset.left
    };
}


exports.$ = $;
exports.Promise = Promise;
exports.gettext = gettext;
exports.escapeHtml = escapeHtml;
exports.getGlobal = getGlobal;
exports.mousePosition = mousePosition;
