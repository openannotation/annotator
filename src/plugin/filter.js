"use strict";

var annotator = require('annotator');

// filter is a plugin module that uses the Annotator.UI.Filter component to
// display a filter bar to allow browsing and searching of annotations on the
// current page.
var filter = function (options) {
    var widget = new annotator.ui.Filter(options);

    return {
        destroy: function () { widget.destroy(); },

        onAnnotationsLoaded: function () { widget.updateHighlights(); },
        onAnnotationCreated: function () { widget.updateHighlights(); },
        onAnnotationUpdated: function () { widget.updateHighlights(); },
        onAnnotationDeleted: function () { widget.updateHighlights(); }
    };
};


annotator.plugin.filter = filter;

exports.filter = filter;
