"use strict";

var annotator = require('annotator');

// editor is a plugin that uses the annotator.ui.Editor component to display an
// editor widget allowing the user to provide a note (and other data) before an
// annotation is created or updated.
function editor(options) {
    var widget = new annotator.ui.Editor(options);

    return {
        destroy: function () { widget.destroy(); },
        beforeAnnotationCreated: function (annotation) {
            return widget.load(annotation);
        },
        beforeAnnotationUpdated: function (annotation) {
            return widget.load(annotation);
        }
    };
}


annotator.plugin.editor = editor;

exports.editor = editor;
