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


// I18N
var gettext = (function () {
    if (typeof global.Gettext === 'function') {
        var _gettext = new global.Gettext({domain: "annotator"});
        return function (msgid) { return _gettext.gettext(msgid); };
    }

    return function (msgid) { return msgid; };
}());


// Returns the absolute position of the mouse relative to the top-left rendered
// corner of the page (taking into account padding/margin/border on the body
// element as necessary).
function mousePosition(event) {
    var body = global.document.body;
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
exports.mousePosition = mousePosition;
