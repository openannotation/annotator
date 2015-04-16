"use strict";

var annotator = require('annotator');


// viewer is a plugin that uses the Annotator.UI.Viewer component to display an
// viewer widget in response to some viewer action (such as mousing over an
// annotator highlight element).
function viewer(options) {
    var widget;

    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    return {
        start: function (app) {
            // Set default handlers for what happens when the user clicks the
            // edit and delete buttons:
            if (typeof options.onEdit === 'undefined') {
                options.onEdit = function (annotation) {
                    app.annotations.update(annotation);
                };
            }
            if (typeof options.onDelete === 'undefined') {
                options.onDelete = function (annotation) {
                    app.annotations['delete'](annotation);
                };
            }

            // Set default handlers that determine whether the edit and delete
            // buttons are shown in the viewer:
            if (typeof options.permitEdit === 'undefined') {
                options.permitEdit = function (annotation) {
                    return app.authz.permits(
                        'update',
                        annotation,
                        app.ident.who()
                    );
                };
            }
            if (typeof options.permitDelete === 'undefined') {
                options.permitDelete = function (annotation) {
                    return app.authz.permits(
                        'delete',
                        annotation,
                        app.ident.who()
                    );
                };
            }

            widget = new annotator.ui.Viewer(options);
        },

        destroy: function () { widget.destroy(); }
    };
}


annotator.plugin.viewer = viewer;

exports.viewer = viewer;
