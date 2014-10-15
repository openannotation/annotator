"use strict";

var Range = require('xpath-range').Range;

var $ = require('../util').$;


// highlightRange wraps the DOM Nodes within the provided range with a highlight
// element of the specified class and returns the highlight Elements.
//
// normedRange - A NormalizedRange to be highlighted.
// cssClass - A CSS class to use for the highlight (default: 'annotator-hl')
//
// Returns an array of highlight Elements.
function highlightRange(normedRange, cssClass) {
    if (typeof cssClass === 'undefined' || cssClass === null) {
        cssClass = 'annotator-hl';
    }
    var white = /^\s*$/;

    var hl = $("<span class='" + cssClass + "'></span>");

    // Ignore text nodes that contain only whitespace characters. This prevents
    // spans being injected between elements that can only contain a restricted
    // subset of nodes such as table rows and lists. This does mean that there
    // may be the odd abandoned whitespace node in a paragraph that is skipped
    // but better than breaking table layouts.
    var nodes = normedRange.textNodes(),
        results = [];
    for (var i = 0, len = nodes.length; i < len; i++) {
        var node = nodes[i];
        if (!white.test(node.nodeValue)) {
            results.push(
                $(node).wrapAll(hl).parent().show()[0]
            );
        }
    }
    return results;
}


// reanchorRange will attempt to normalize a range, swallowing Range.RangeErrors
// for those ranges which are not reanchorable in the current document.
function reanchorRange(range, rootElement) {
    try {
        return Range.sniff(range).normalize(rootElement);
    } catch (e) {
        if (!(e instanceof Range.RangeError)) {
            // Oh Javascript, why you so crap? This will lose the traceback.
            throw(e);
        }
        // Otherwise, we simply swallow the error. Callers are responsible
        // for only trying to draw valid highlights.
    }
    return null;
}


// Highlighter provides a simple way to draw highlighted <span> tags over
// annotated ranges within a document.
//
// element - The root Element on which to dereference ranges and draw
//           highlights.
// options - An options Object containing configuration options for the plugin.
//           See `Highlighter.options` for available options.
//
function Highlighter(element, options) {
    this.element = element;
    this.options = $.extend(true, {}, Highlighter.options, options);
}

Highlighter.prototype.destroy = function () {
    $(this.element)
        .find("." + this.options.highlightClass)
        .each(function (_, el) {
            $(el).contents().insertBefore(el);
            $(el).remove();
        });
};

// Public: Draw highlights for the given ranges.
//
// range - An Array of Range Objects for which to draw highlights.
//
// Returns an Array of highlight elements.
Highlighter.prototype.draw = function (ranges) {
    var highlights = [];
    var normedRanges = [];

    for (var i = 0, ilen = ranges.length; i < ilen; i++) {
        var r = reanchorRange(ranges[i], this.element);
        if (r !== null) {
            normedRanges.push(r);
        }
    }

    for (var j = 0, jlen = normedRanges.length; j < jlen; j++) {
        var normed = normedRanges[j];
        highlights.push(highlightRange(normed, this.options.highlightClass));
    }

    return Array.prototype.concat.apply([], highlights);
};

// Public: Remove a set of highlights.
//
// highlight - A Array of highlight elements to remove.
//
// Returns nothing.
Highlighter.prototype.undraw = function (highlights) {
    for (var i = 0, len = highlights.length; i < len; i++) {
        var h = highlights[i];
        if (h.parentNode !== null) {
            $(h).replaceWith(h.childNodes);
        }
    }
};

Highlighter.options = {
    // The CSS class to apply to drawn highlights
    highlightClass: 'annotator-hl'
};


exports.Highlighter = Highlighter;
