"use strict";

var annotator = require('annotator');


// Highlighter is a simple plugin that uses the Annotator.UI.Highlighter
// component to draw/undraw highlights automatically when annotations are
// created and removed.
function Highlighter(element, options, highlighter) {
    if (typeof highlighter === 'undefined' || highlighter === null) {
        highlighter = annotator.ui.Highlighter;
    }

    // Store the constructor in an uppercased variable
    var Hl = highlighter;

    return function () {
        var hl = new Hl(element, options);

        return {
            onDestroy: function () { hl.destroy(); },
            onAnnotationsLoaded: function (anns) { hl.drawAll(anns); },
            onAnnotationCreated: function (ann) { hl.draw(ann); },
            onAnnotationDeleted: function (ann) { hl.undraw(ann); },
            onAnnotationUpdated: function (ann) { hl.redraw(ann); }
        };
    };
}


annotator.plugin.Highlighter = Highlighter;

exports.Highlighter = Highlighter;
