"use strict";

var annotator = require('annotator');


// highlighter is a simple plugin that uses the Annotator.UI.Highlighter
// component to draw/undraw highlights automatically when annotations are
// created and removed.
function highlighter(element, options) {
    var widget = annotator.ui.Highlighter(element, options);

    return {
        destroy: function () { widget.destroy(); },
        onAnnotationsLoaded: function (anns) { widget.drawAll(anns); },
        onAnnotationCreated: function (ann) { widget.draw(ann); },
        onAnnotationDeleted: function (ann) { widget.undraw(ann); },
        onAnnotationUpdated: function (ann) { widget.redraw(ann); }
    };
}


annotator.plugin.highlighter = highlighter;

exports.highlighter = highlighter;
