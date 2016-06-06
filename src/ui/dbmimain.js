/*package annotator.ui */
"use strict";

var util = require('../util');
var xUtil = require('../xutil');
var textselector = require('./textselector');

// ddi
var ddiadder = require('./../ddiPlugin/adder');
var ddihighlighter = require('./../ddiPlugin/highlighter');
var ddieditor = require('./../ddiPlugin/editor');
var ddiviewer = require('./../ddiPlugin/viewer');

// highlight
var hladder = require('./../drugPlugin/adder');
var hleditor = require('./../drugPlugin/editor');
var hlhighlighter = require('./../drugPlugin/highlighter');
var hlviewer = require('./../drugPlugin/viewer');

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
            var serializedRange = r.serialize(contextEl, ignoreSelector)
            serializedRanges.push(serializedRange);
        }

        //console.log("dbmimain - annFac - seRanges:" + JSON.stringify(serializedRanges));

        //console.log("dbmimain - exactTxt:" + text.join(' / ') + "|");
        var prefix = "", suffix = "";
        prefix = getTxtFromNode(ranges[0].start, false, ignoreSelector, 50);
        suffix = getTxtFromNode(ranges[0].end, true, ignoreSelector, 50);

        //console.log("dbmimain - prefix:" + prefix);
        //console.log("dbmimain - suffix:" + suffix);

        return {
            quote: text.join(' / '),
            ranges: serializedRanges,
            target: {
                source: "url",
                selector: {
                    "@type": "TextQuoteSelector",
                    "exact": text.join(' / '),
                    "prefix": prefix, 
                    "suffix": suffix 
                }
            }
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

            //alert('ddi main - load - user ident:' + u)

            // Do not show field if no user is set
            if (typeof u === 'undefined' || u === null || u == "") {
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
            if (typeof u === 'undefined' || u === null || u == "") {
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
/*
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

    // add checkbox for set delete permission 
    editor.addField({
        type: 'checkbox',
        label: _t('Allow anyone to <strong>delete</strong> this annotation'),
        load: createLoadCallback('delete'),
        submit: createSubmitCallback('delete')
    });
    */
}


/**

 */
function main(options) {
    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    options.element = options.element || global.document.body;
    options.editorExtensions = options.editorExtensions || [];
    options.viewerExtensions = options.viewerExtensions || [];

    // Local helpers
    var makeHLAnnotation = annotationFactory(options.element, '.annotator-hl');
    //var makeDDIAnnotation = annotationFactory(options.element, '.annotator-ddi');


    // Object to hold local state
    var s = {
        interactionPoint: null
    };

    function start(app) {
        var ident = app.registry.getUtility('identityPolicy');
        var authz = app.registry.getUtility('authorizationPolicy');

        console.log("[INFO] dbmimain start()");

        // ddi adder
        s.ddiadder = new ddiadder.ddiAdder({
            onCreate: function (ann) {
                app.annotations.create(ann);
            }
        });
        s.ddiadder.attach();

        // highlight adder
        s.hladder = new hladder.Adder({
            onCreate: function (ann) {
                app.annotations.create(ann);
            }
        });
        s.hladder.attach();

        // highlight ddi editor
        s.ddieditor = new ddieditor.ddiEditor({
            extensions: options.editorExtensions
        });
        s.ddieditor.attach();

        s.hleditor = new hleditor.Editor({
            extensions: options.editorExtensions
        });
        s.hleditor.attach();

        addPermissionsCheckboxes(s.ddieditor, ident, authz);
        //addPermissionsCheckboxes(s.hleditor, ident, authz);

        //highlighter
        s.hlhighlighter = new hlhighlighter.Highlighter(options.element);
        s.ddihighlighter = new ddihighlighter.ddiHighlighter(options.element);


        s.textselector = new textselector.TextSelector(options.element, {
            onSelection: function (ranges, event) {
                if (ranges.length > 0) {
                    //var ddiAnnotation = makeDDIAnnotation(ranges);
                    var hlAnnotation = makeHLAnnotation(ranges);

                    s.interactionPoint = util.mousePosition(event);
                    s.hladder.load(hlAnnotation, s.interactionPoint);
                    s.ddiadder.load(hlAnnotation, s.interactionPoint);
                    //s.ddiadder.load(ddiAnnotation, s.interactionPoint);

                } else {
                    s.hladder.hide();
                    s.ddiadder.hide();

                }
            }
        });

        // ddi viewer
        s.ddiviewer = new ddiviewer.ddiViewer({
            onEdit: function (ann) {
                // Copy the interaction point from the shown viewer:
                s.interactionPoint = util.$(s.ddiviewer.element)
                    .css(['top', 'left']);
                if (ann.annotationType == "DDI"){
                    app.annotations.update(ann);
                }
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

        s.ddiviewer.attach();

        // highlight viewer

        s.hlviewer = new hlviewer.Viewer({
            onEdit: function (ann) {
                // Copy the interaction point from the shown viewer:
                s.interactionPoint = util.$(s.hlviewer.element)
                    .css(['top', 'left']);
                if (ann.annotationType == "DrugMention"){
                    app.annotations.update(ann);
                }
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
        s.hlviewer.attach();


        injectDynamicStyle();
    }

    return {
        start: start,

        destroy: function () {
            /*s.adder.destroy();
            s.editor.destroy();
            s.highlighter.destroy();
            s.textselector.destroy();
            s.viewer.destroy();*/
            s.hleditor.destroy();
            s.hlhighlighter.destroy();
            s.hladder.destroy();
            s.textselector.destroy();
            s.hlviewer.destroy();
            s.ddiadder.destroy();
            s.ddieditor.destroy();
            s.ddihighlighter.destroy();
            s.ddiviewer.destroy();
            removeDynamicStyle();
        },

        annotationsLoaded: function (anns) {
            s.hlhighlighter.drawAll(anns);
            s.ddihighlighter.drawAll(anns);

        },
        annotationCreated: function (ann) {
            // yifan draw annotation on text 
            if (ann.annotationType == "DDI"){
                s.ddihighlighter.draw(ann);

            } else if (ann.annotationType == "DrugMention"){
                s.hlhighlighter.draw(ann);
            } else {
                alert('[WARNING] main.js - annotationCreated - annot type not defined: ' + ann.annotationType);
            }
        },
        annotationDeleted: function (ann) {
            s.hlhighlighter.undraw(ann);
            s.ddihighlighter.undraw(ann);

        },
        annotationUpdated: function (ann) {

            if (ann.annotationType == "DDI"){
                s.ddihighlighter.redraw(ann);
            } else if (ann.annotationType == "DrugMention"){
                s.hlhighlighter.redraw(ann);
            } else {
                alert('[WARNING] main.js - annotationUpdated - annot type not defined: ' + ann.annotationType);
            }

        },

        beforeAnnotationCreated: function (annotation) {
            // Editor#load returns a promise that is resolved if editing
            // completes, and rejected if editing is cancelled. We return it
            // here to "stall" the annotation process until the editing is
            // done.

            // yifan: call different editor based on annotation type
            if (annotation.annotationType == "DDI"){
                return s.ddieditor.load(s.interactionPoint,annotation);
            } else if (annotation.annotationType == "DrugMention") {
                // return s.hleditor.load(annotation, s.interactionPoint);
                // yifan: not show editor when typed as Drug mention
                return null;
            } else {
                //return s.ddieditor.load(annotation, s.interactionPoint);
                return null;
            }


        },

        beforeAnnotationUpdated: function (annotation) {

            //alert('testmain.js - beforeAnnotationUpdated - annotation type defined: ' + annotation.annotationType);

            if (annotation.annotationType == "DDI"){
                return s.ddieditor.load(s.interactionPoint,annotation);
            } else if (annotation.annotationType == "DrugMention") {
                // return s.hleditor.load(annotation, s.interactionPoint);
                return null;
            } else {
                //return s.ddieditor.load(annotation, s.interactionPoint);
                return null;
            }
        }
    };
}


function getTxtFromNode(node, isSuffix, ignoreSelector, maxLength){

    var origParent;
    if (ignoreSelector) {
        origParent = $(node).parents(":not(" + ignoreSelector + ")").eq(0);
    } else {
        origParent = $(node).parent();
    }
    
    var textNodes = xUtil.getTextNodes(origParent);
    var nodes;
    var contents = "";

    if (!isSuffix){
        nodes = textNodes.slice(0, textNodes.index(node));
        for (var _i = 0, _len = nodes.length; _i < _len; _i++) {
            contents += nodes[_i].nodeValue;
        }
        if (contents.length > maxLength){
            contents = contents.substring(contents.length - maxLength);
        }

    } else {
        nodes = textNodes.slice(textNodes.index(node) + 1, textNodes.length);   
        for (var _i = 0, _len = nodes.length; _i < _len; _i++) {
            contents += nodes[_i].nodeValue;
        }
        if (contents.length > maxLength){
            contents = contents.substring(0, maxLength);
        }
        
    }

    return contents;
}




exports.main = main;
