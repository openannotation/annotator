"use strict";

var annotator = require('annotator');

// filter is a plugin module that uses the Annotator.UI.Filter component to
// display a filter bar to allow browsing and searching of annotations on the
// current page.
var filter = function (options) {
    var widget = new annotator.ui.Filter(options);

    return {
        destroy: function () { widget.destroy(); },

        annotationsLoaded: function () { widget.updateHighlights(); },
        annotationCreated: function () { widget.updateHighlights(); },
        annotationUpdated: function () { widget.updateHighlights(); },
        annotationDeleted: function () { widget.updateHighlights(); }
    };
};


annotator.plugin.filter = filter;

exports.filter = filter;
