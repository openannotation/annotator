"use strict";

var Annotator = require('annotator-plugintools').Annotator;

// Editor is a plugin that uses the Annotator.UI.Editor component to display an
// editor widget allowing the user to provide a note (and other data) before an
// annotation is created or updated.
function Editor(options, editor) {
    if (typeof editor === 'undefined' || editor === null) {
        editor = Annotator.UI.Editor;
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


Annotator.Plugin.Editor = Editor;

exports.Editor = Editor;
