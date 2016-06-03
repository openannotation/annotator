/*package annotator.ui */
"use strict";

var util = require('../util');
var xUtil = require('../xutil');
var textselector = require('./textselector');

// mp
var mpadder = require('./../mpPlugin/adder');
var mphighlighter = require('./../mpPlugin/highlighter');
var mpeditor = require('./../mpPlugin/editor');
var mpviewer = require('./../mpPlugin/viewer');

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

        //console.log("mpmain - annFac - seRanges:" + JSON.stringify(serializedRanges));
        //console.log("mpmain - exactTxt:" + text.join(' / ') + "|");

        var prefix = "", suffix = "";
        prefix = getTxtFromNode(ranges[0].start, false, ignoreSelector, 50);
        suffix = getTxtFromNode(ranges[0].end, true, ignoreSelector, 50);

        return {
            argues : {
                ranges: serializedRanges,
                hasTarget: {
                    hasSelector: {
                        "@type": "TextQuoteSelector",
                        "exact": text.join(' / '),
                        "prefix": prefix, 
                        "suffix": suffix 
                    }
                },
                supportsBy : []
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

            //alert('mp main - load - user ident:' + u)

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

    console.log("[INFO] mpmain start()");
    console.log(options.email);
    console.log(options.source);

    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    options.element = options.element || global.document.body;
    options.editorExtensions = options.editorExtensions || [];
    options.viewerExtensions = options.viewerExtensions || [];

    // Local helpers
    var makeHLAnnotation = annotationFactory(options.element, '.annotator-hl');
    //var makeMPAnnotation = annotationFactory(options.element, '.annotator-mp');

    // Object to hold local state
    var s = {
        interactionPoint: null
    };

    function start(app) {
        var ident = app.registry.getUtility('identityPolicy');
        var authz = app.registry.getUtility('authorizationPolicy');

        // mp adder
        s.mpadder = new mpadder.mpAdder({
            onCreate: function (ann) {
                console.log("mpmain - onCreate function");
                app.annotations.create(ann);
            },
            onUpdate: function (ann) {
                console.log("mpmain - onUpdate function");
                app.annotations.update(ann);
            }
        });
        s.mpadder.attach();

        // highlight adder
        s.hladder = new hladder.Adder({
            onCreate: function (ann) {
                app.annotations.create(ann);
            },
            onUpdate: function (ann) {
                app.annotations.update(ann);
            }
        });
        s.hladder.attach();

        // mp editor
        s.mpeditor = new mpeditor.mpEditor({
            extensions: options.editorExtensions,
            onDelete: function (ann) {
                var editorType = $("#mp-editor-type").html();
                if (editorType == "claim") { 
                    // delete confirmation for claim
                    $( "#dialog-claim-delete-confirm" ).dialog({
                        resizable: false,
                        height: 'auto',
                        width: '400px',
                        modal: true,
                        buttons: {
                            "Confirm": function() {
                                $( this ).dialog( "close" );
                                console.log("mpmain - confirm deletion");

                                app.annotations.delete(ann);
                                showAnnTable();
                                s.mphighlighter.undraw(ann);  

                                // clean field name and annotation id
                                $("#mp-editor-type").html('');           
                                $("#mp-annotation-work-on").html('');         
                            },
                            "Cancel": function() {
                            $( this ).dialog( "close" );
                            }
                        }
                    });
                } else {
                    // delete confirmation for data & material
                    $( "#dialog-data-delete-confirm" ).dialog({
                        resizable: false,
                        height: 'auto',
                        width: '400px',
                        modal: true,
                        buttons: {                        
                            "Confirm": function() {
                                $( this ).dialog( "close" );
                                if (editorType == "participants") {
                                    ann.argues.supportsBy[0].supportsBy.supportsBy.participants = {};
                                } else if (editorType == "dose1") {
                                    ann.argues.supportsBy[0].supportsBy.supportsBy.drug1Dose = {};        
                                } else if (editorType == "dose2") {
                                    ann.argues.supportsBy[0].supportsBy.supportsBy.drug2Dose = {};         
                                } else if (editorType == "auc" || editorType == "cmax" || editorType == "cl" || editorType == "halflife") {
                                    ann.argues.supportsBy[0][editorType] = {}; 
                                }                                            
                                if (typeof s.mpeditor.dfd !== 'undefined' && s.mpeditor.dfd !== null) {
                                    s.mpeditor.dfd.resolve();
                                }        
                                showAnnTable();                                   
                            },
                            "Cancel": function() {
                                $( this ).dialog( "close" );
                            }
                        }
                    });                    
                }                
            }
        });
        s.mpeditor.attach();

        s.hleditor = new hleditor.Editor({
            extensions: options.editorExtensions
        });
        s.hleditor.attach();

        addPermissionsCheckboxes(s.mpeditor, ident, authz);
        //addPermissionsCheckboxes(s.hleditor, ident, authz);

        //highlighter
        s.hlhighlighter = new hlhighlighter.Highlighter(options.element);
        s.mphighlighter = new mphighlighter.mpHighlighter(options.element);

        // select text, then load normed ranges to adder
        s.textselector = new textselector.TextSelector(options.element, {
            onSelection: function (ranges, event) {
                if (ranges.length > 0) {
                    //var mpAnnotation = makeMPAnnotation(ranges);
                    var hlAnnotation = makeHLAnnotation(ranges);

                    s.interactionPoint = util.mousePosition(event);
                    s.hladder.load(hlAnnotation, s.interactionPoint);
                    s.mpadder.load(hlAnnotation, s.interactionPoint);
                    //s.mpadder.load(mpAnnotation, s.interactionPoint);

                } else {
                    s.hladder.hide();
                    s.mpadder.hide();
                }
            }
        });

        // mp viewer
        s.mpviewer = new mpviewer.mpViewer({
            onEdit: function (ann, field) {
                // Copy the interaction point from the shown viewer:
                s.interactionPoint = util.$(s.mpviewer.element)
                    .css(['top', 'left']);
                if (ann.annotationType == "MP"){
                    var annotationId = ann.id;
                    if (document.getElementById(annotationId + field))
                        document.getElementById(annotationId + field).scrollIntoView(true);
                    if (field == "claim") {
                        $('#quote').show();
                        claimEditorLoad();
                    }
                    else { 
                        $('#quote').hide();
                        switchDataForm(field);                               
                    }
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
        s.mpviewer.attach();


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
            s.hleditor.destroy();
            s.hlhighlighter.destroy();
            s.hladder.destroy();
            s.textselector.destroy();
            s.hlviewer.destroy();
            s.mpadder.destroy();
            s.mpeditor.destroy();
            s.mphighlighter.destroy();
            s.mpviewer.destroy();
            removeDynamicStyle();
        },

        annotationsLoaded: function (anns) {
            s.hlhighlighter.drawAll(anns);
            s.mphighlighter.drawAll(anns);
        },

        beforeAnnotationCreated: function (annotation) {
            // Editor#load returns a promise that is resolved if editing
            // completes, and rejected if editing is cancelled. We return it
            // here to "stall" the annotation process until the editing is
            // done.

		    annotation.rawurl = options.source;
    		annotation.uri = options.source.replace(/[\/\\\-\:\.]/g, "");		
		    annotation.email = options.email;

            // call different editor based on annotation type
            if (annotation.annotationType == "MP"){
                return s.mpeditor.load(s.interactionPoint,annotation);
            } else if (annotation.annotationType == "DrugMention") {
                // return s.hleditor.load(annotation, s.interactionPoint);
                // not show editor when typed as Drug mention
                return null;
            } else {
                //return s.mpeditor.load(annotation, s.interactionPoint);
                return null;
            }
        },
        annotationCreated: function (ann) {
            if (ann.annotationType == "MP"){
                console.log("mpmain - annotationCreated called");
                s.mphighlighter.draw(ann);
                $("#mp-annotation-work-on").html(ann.id);
                annotationTable(ann.rawurl, ann.email);
                // providing options of add another claim or data on current span
                $( "#claim-dialog-confirm" ).dialog({
                    resizable: false,
                    height: 'auto',
                    width: '400px',
                    modal: true,
                    buttons: {
                        "Add another claim": function() {
                            $( this ).dialog( "close" ); 
                            showEditor();
                            claimEditorLoad();
                            $("#mp-editor-type").html("claim");
                            var newAnn = (JSON.parse(JSON.stringify(ann)));
                            newAnn.argues.qualifiedBy = {};
                            app.annotations.create(newAnn);
 
                        },
                        "Add data": function() {
                            $( this ).dialog( "close" );

                            if (ann.argues.supportsBy.length == 0){ 
                                var data = {type : "mp:data", auc : {}, cmax : {}, cl : {}, halflife : {}, supportsBy : {type : "mp:method", supportsBy : {type : "mp:material", participants : {}, drug1Dose : {}, drug2Dose : {}}}};
                                ann.argues.supportsBy.push(data); 
                                // copy text selector as default span for data
                                ann.dataTarget = ann.argues.hasTarget;
                                ann.dataRanges = ann.argues.ranges;
                            } 
                            showEditor();
                            dataEditorLoad(ann, "participants", ann.id);

                        },
                        "Done": function() {
                            $( this ).dialog( "close" );
                            showAnnTable();  
                        }
                    }
                });
                

            } else if (ann.annotationType == "DrugMention"){
                s.hlhighlighter.draw(ann);
            } else {
                alert('[WARNING] main.js - annotationCreated - annot type not defined: ' + ann.annotationType);
            }
        },

        beforeAnnotationUpdated: function (annotation) {
            console.log("mpmain - beforeAnnotationUpdated");

            if (annotation.annotationType == "MP"){
                return s.mpeditor.load(s.interactionPoint,annotation);
            } else if (annotation.annotationType == "DrugMention") {
                // return s.hleditor.load(annotation, s.interactionPoint);
                return null;
            } else {
                return null;
            }
        },
        annotationUpdated: function (ann) {
            console.log("mpmain - annotationUpdated called");
            if (ann.annotationType == "MP"){
                s.mphighlighter.redraw(ann);
                $("#mp-annotation-work-on").html(ann.id);
                annotationTable(ann.rawurl, ann.email);
                
            } else if (ann.annotationType == "DrugMention"){
                s.hlhighlighter.redraw(ann);
            } else {
                alert('[WARNING] main.js - annotationUpdated - annot type not defined: ' + ann.annotationType);
            }
        },

        // beforeAnnotationDeleted: function(ann){
        // },
        annotationDeleted: function (ann) {
            console.log("mpmain - annotationDeleted called");
            s.mphighlighter.undraw(ann);
            s.hlhighlighter.undraw(ann);
            showAnnTable();
            setTimeout(function(){
                annotationTable(options.source, options.email);
            },1000);
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
