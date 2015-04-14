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
        configure: function (reg) {
            // Set default handlers for what happens when the user clicks the
            // edit and delete buttons:
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
                    return reg.authz.permits(
                        'update',
                        annotation,
                        reg.ident.who()
                    );
                };
            }
            if (typeof options.permitDelete === 'undefined') {
                options.permitDelete = function (annotation) {
                    return reg.authz.permits(
                        'delete',
                        annotation,
                        reg.ident.who()
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
