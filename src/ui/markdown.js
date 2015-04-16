"use strict";

var util = require('../util');

var g = util.getGlobal();
var _t = util.gettext;

function markdown() {
    var converter = null;

    if (g.Showdown && typeof g.Showdown.converter === 'function') {
        converter = new g.Showdown.converter();
    } else {
        console.warn(_t("To use the Markdown plugin, you must" +
        " include Showdown into the page first."));
    }

    // Converts provided text into markdown.
    //
    // text - A String of Markdown to render as HTML.
    //
    // Examples
    //
    // plugin.convert('This is _very_ basic [Markdown](http://daringfireball.com)')
    // # => Returns "This is <em>very<em> basic <a href="http://...">Markdown</a>"
    //
    // Returns HTML string.
    function convert (text) {
        text = util.escapeHtml(text || '');
        return converter ? converter.makeHtml(text) : text;
    }

    return {
        convert: convert
    };
}

exports.markdown = markdown;
