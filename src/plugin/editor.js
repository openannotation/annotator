"use strict";

var annotator = require('annotator');

// Editor is a plugin that uses the annotator.ui.Editor component to display an
// editor widget allowing the user to provide a note (and other data) before an
// annotation is created or updated.
function Editor(options, editor) {
    if (typeof editor === 'undefined' || editor === null) {
        editor = annotator.ui.Editor;
    }

    // Store the constructor in an uppercased variable
    var Ed = editor;

    return function () {
        var ed = new Ed(options);

        return {
            onDestroy: function () { ed.destroy(); },
            onBeforeAnnotationCreated: function (annotation) {
                return ed.load(annotation);
            },
            onBeforeAnnotationUpdated: function (annotation) {
                return ed.load(annotation);
            }
        };
    };
}


annotator.plugin.Editor = Editor;

exports.Editor = Editor;
