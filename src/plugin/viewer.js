"use strict";

var Annotator = require('annotator-plugintools').Annotator;


// Viewer is a plugin that uses the Annotator.UI.Viewer component to display an
// viewer widget in response to some viewer action (such as mousing over an
// annotator highlight element).
function Viewer(options, viewer) {
    if (typeof viewer === 'undefined' || viewer === null) {
        viewer = Annotator.UI.Viewer;
    }

    // Store the constructor in an uppercased variable
    var Vw = viewer;

    return function (reg) {
        // Set default handlers for what happens when the user clicks the edit
        // and delete buttons:
        if (typeof options.onEdit === 'undefined') {
            options.onEdit = function (annotation) {
                reg.annotations.update(annotation);
            };
        }
        if (typeof options.onDelete === 'undefined') {
            options.onDelete = function (annotation) {
                reg.annotations['delete'](annotation);
            };
        }

        // Set default handlers that determine whether the edit and delete
        // buttons are shown in the viewer:
        if (typeof options.permitEdit === 'undefined') {
            options.permitEdit = function (annotation) {
                return reg.authorizer.permits(
                    'update',
                    annotation,
                    reg.identifier.who()
                );
            };
        }
        if (typeof options.permitDelete === 'undefined') {
            options.permitDelete = function (annotation) {
                return reg.authorizer.permits(
                    'delete',
                    annotation,
                    reg.identifier.who()
                );
            };
        }

        var vw = new Vw(options);

        return {
            onDestroy: function () { vw.destroy(); }
        };
    };
}


Annotator.Plugin.Viewer = Viewer;

exports.Viewer = Viewer;
