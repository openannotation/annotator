"use strict";

var Util = require('../util');

var g = Util.getGlobal(),
    _t = Util.gettext;

function createMarkdownPlugin () {
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
        text = Util.escapeHtml(text || '');
        return converter ? converter.makeHtml(text) : text;
    }

    return {
        convert: convert
    };
}

exports.createMarkdownPlugin = createMarkdownPlugin;
