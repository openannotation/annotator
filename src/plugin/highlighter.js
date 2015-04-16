"use strict";

var annotator = require('annotator');


// highlighter is a simple plugin that uses the Annotator.UI.Highlighter
// component to draw/undraw highlights automatically when annotations are
// created and removed.
function highlighter(element, options) {
    var widget = annotator.ui.highlighter.Highlighter(element, options);

    return {
        destroy: function () { widget.destroy(); },
        annotationsLoaded: function (anns) { widget.drawAll(anns); },
        annotationCreated: function (ann) { widget.draw(ann); },
        annotationDeleted: function (ann) { widget.undraw(ann); },
        annotationUpdated: function (ann) { widget.redraw(ann); }
    };
}


annotator.plugin.highlighter = highlighter;

exports.highlighter = highlighter;
