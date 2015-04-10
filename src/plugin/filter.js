"use strict";

var annotator = require('annotator');

// Filter is a plugin that uses the Annotator.UI.Filter component to display a
// filter bar to allow browsing and searching of annotations on the current
// page.
function Filter(options, filter) {
    if (typeof filter === 'undefined' || filter === null) {
        filter = annotator.ui.Filter;
    }

    // Store the constructor in an uppercased variable
    var Fl = filter;

    return function () {
        var fl = new Fl(options);

        return {
            onDestroy: function () { fl.destroy(); },
            onAnnotationsLoaded: function () { fl.updateHighlights(); },
            onAnnotationCreated: function () { fl.updateHighlights(); },
            onAnnotationUpdated: function () { fl.updateHighlights(); },
            onAnnotationDeleted: function () { fl.updateHighlights(); }
        };
    };
}


annotator.plugin.Filter = Filter;

exports.Filter = Filter;
