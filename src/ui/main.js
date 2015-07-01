/*package annotator.ui */
"use strict";

var util = require('../util');

var adder = require('./adder');
var editor = require('./editor');
var highlighter = require('./highlighter');
var textselector = require('./textselector');
var viewer = require('./viewer');

var _t = util.gettext;


// trim strips whitespace from either end of a string.
//
// This usually exists in native code, but not in IE8.
function trim(s) {
    if (typeof String.prototype.trim === 'function') {
        return String.prototype.trim.call(s);
    } else {
        return s.replace(/^[\s\xA0]+|[\s\xA0]+$/g, '');
    }
}


// annotationFactory returns a function that can be used to construct an
// annotation from a list of selected ranges.
function annotationFactory(contextEl, ignoreSelector) {
    return function (ranges) {
        var text = [],
            serializedRanges = [];

        for (var i = 0, len = ranges.length; i < len; i++) {
            var r = ranges[i];
            text.push(trim(r.text()));
            serializedRanges.push(r.serialize(contextEl, ignoreSelector));
        }

        return {
            quote: text.join(' / '),
            ranges: serializedRanges
        };
    };
}


// maxZIndex returns the maximum z-index of all elements in the provided set.
function maxZIndex(elements) {
    var max = -1;
    for (var i = 0, len = elements.length; i < len; i++) {
        var $el = util.$(elements[i]);
        if ($el.css('position') !== 'static') {
            // Use parseFloat since we may get scientific notation for large
            // values.
            var zIndex = parseFloat($el.css('z-index'));
            if (zIndex > max) {
                max = zIndex;
            }
        }
    }
    return max;
}


// Helper function to inject CSS into the page that ensures Annotator elements
// are displayed with the highest z-index.
function injectDynamicStyle() {
    util.$('#annotator-dynamic-style').remove();

    var sel = '*' +
              ':not(annotator-adder)' +
              ':not(annotator-outer)' +
              ':not(annotator-notice)' +
              ':not(annotator-filter)';

    // use the maximum z-index in the page
    var max = maxZIndex(util.$(global.document.body).find(sel).get());

    // but don't go smaller than 1010, because this isn't bulletproof --
    // dynamic elements in the page (notifications, dialogs, etc.) may well
    // have high z-indices that we can't catch using the above method.
    max = Math.max(max, 1000);

    var rules = [
        ".annotator-adder, .annotator-outer, .annotator-notice {",
        "  z-index: " + (max + 20) + ";",
        "}",
        ".annotator-filter {",
        "  z-index: " + (max + 10) + ";",
        "}"
    ].join("\n");

    util.$('<style>' + rules + '</style>')
        .attr('id', 'annotator-dynamic-style')
        .attr('type', 'text/css')
        .appendTo('head');
}


// Helper function to remove dynamic stylesheets
function removeDynamicStyle() {
    util.$('#annotator-dynamic-style').remove();
}


// Helper function to add permissions checkboxes to the editor
function addPermissionsCheckboxes(editor, ident, authz) {
    function createLoadCallback(action) {
        return function loadCallback(field, annotation) {
            field = util.$(field).show();

            var u = ident.who();
            var input = field.find('input');

            // Do not show field if no user is set
            if (typeof u === 'undefined' || u === null) {
                field.hide();
            }

            // Do not show field if current user is not admin.
            if (!(authz.permits('admin', annotation, u))) {
                field.hide();
            }

            // See if we can authorise without a user.
            if (authz.permits(action, annotation, null)) {
                input.attr('checked', 'checked');
            } else {
                input.removeAttr('checked');
            }
        };
    }

    function createSubmitCallback(action) {
        return function submitCallback(field, annotation) {
            var u = ident.who();

            // Don't do anything if no user is set
            if (typeof u === 'undefined' || u === null) {
                return;
            }

            if (!annotation.permissions) {
                annotation.permissions = {};
            }
            if (util.$(field).find('input').is(':checked')) {
                delete annotation.permissions[action];
            } else {
                // While the permissions model allows for more complex entries
                // than this, our UI presents a checkbox, so we can only
                // interpret "prevent others from viewing" as meaning "allow
                // only me to view". This may want changing in the future.
                annotation.permissions[action] = [
                    authz.authorizedUserId(u)
                ];
            }
        };
    }

    editor.addField({
        type: 'checkbox',
        label: _t('Allow anyone to <strong>view</strong> this annotation'),
        load: createLoadCallback('read'),
        submit: createSubmitCallback('read')
    });

    editor.addField({
        type: 'checkbox',
        label: _t('Allow anyone to <strong>edit</strong> this annotation'),
        load: createLoadCallback('update'),
        submit: createSubmitCallback('update')
    });
}


/**
 * function:: main([options])
 *
 * A module that provides a default user interface for Annotator that allows
 * users to create annotations by selecting text within (a part of) the
 * document.
 *
 * Example::
 *
 *     app.include(annotator.ui.main);
 *
 * :param Object options:
 *
 *   .. attribute:: options.element
 *
 *      A DOM element to which event listeners are bound. Defaults to
 *      ``document.body``, allowing annotation of the whole document.
 *
 *   .. attribute:: options.editorExtensions
 *
 *      An array of editor extensions. See the
 *      :class:`~annotator.ui.editor.Editor` documentation for details of editor
 *      extensions.
 *
 *   .. attribute:: options.viewerExtensions
 *
 *      An array of viewer extensions. See the
 *      :class:`~annotator.ui.viewer.Viewer` documentation for details of viewer
 *      extensions.
 *
 */
function main(options) {
    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    options.element = options.element || global.document.body;
    options.editorExtensions = options.editorExtensions || [];
    options.viewerExtensions = options.viewerExtensions || [];

    // Local helpers
    var makeAnnotation = annotationFactory(options.element, '.annotator-hl');

    // Object to hold local state
    var s = {
        interactionPoint: null
    };

    function start(app) {
        var ident = app.registry.getUtility('identityPolicy');
        var authz = app.registry.getUtility('authorizationPolicy');

        s.adder = new adder.Adder({
            onCreate: function (ann) {
                app.annotations.create(ann);
            }
        });
        s.adder.attach();

        s.editor = new editor.Editor({
            extensions: options.editorExtensions
        });
        s.editor.attach();

        addPermissionsCheckboxes(s.editor, ident, authz);

        s.highlighter = new highlighter.Highlighter(options.element);

        s.textselector = new textselector.TextSelector(options.element, {
            onSelection: function (ranges, event) {
                if (ranges.length > 0) {
                    var annotation = makeAnnotation(ranges);
                    s.interactionPoint = util.mousePosition(event);
                    s.adder.load(annotation, s.interactionPoint);
                } else {
                    s.adder.hide();
                }
            }
        });

        s.viewer = new viewer.Viewer({
            onEdit: function (ann) {
                // Copy the interaction point from the shown viewer:
                s.interactionPoint = util.$(s.viewer.element)
                                         .css(['top', 'left']);

                app.annotations.update(ann);
            },
            onDelete: function (ann) {
                app.annotations['delete'](ann);
            },
            permitEdit: function (ann) {
                return authz.permits('update', ann, ident.who());
            },
            permitDelete: function (ann) {
                return authz.permits('delete', ann, ident.who());
            },
            autoViewHighlights: options.element,
            extensions: options.viewerExtensions
        });
        s.viewer.attach();

        injectDynamicStyle();
    }

    return {
        start: start,

        destroy: function () {
            s.adder.destroy();
            s.editor.destroy();
            s.highlighter.destroy();
            s.textselector.destroy();
            s.viewer.destroy();
            removeDynamicStyle();
        },

        annotationsLoaded: function (anns) { s.highlighter.drawAll(anns); },
        annotationCreated: function (ann) { s.highlighter.draw(ann); },
        annotationDeleted: function (ann) { s.highlighter.undraw(ann); },
        annotationUpdated: function (ann) { s.highlighter.redraw(ann); },

        beforeAnnotationCreated: function (annotation) {
            // Editor#load returns a promise that is resolved if editing
            // completes, and rejected if editing is cancelled. We return it
            // here to "stall" the annotation process until the editing is
            // done.
            return s.editor.load(annotation, s.interactionPoint);
        },

        beforeAnnotationUpdated: function (annotation) {
            return s.editor.load(annotation, s.interactionPoint);
        }
    };
}


exports.main = main;
