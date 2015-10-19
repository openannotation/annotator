var Widget = require('../widget').Widget,
    util = require('../../util');

var Editor = require('../editor').Editor

var $ = util.$;
var _attris = util.getkeys;
var _t = util.gettext;
var Promise = util.Promise;
var NS = "annotator-editor";

// id returns an identifier unique within this session
var id = (function () {
    var counter;
    counter = -1;
    return function () {
        return counter += 1;
    };
}());



// preventEventDefault prevents an event's default, but handles the condition
// that the event is null or doesn't have a preventDefault function.
function preventEventDefault(event) {
    if (typeof event !== 'undefined' &&
        event !== null &&
        typeof event.preventDefault === 'function') {
        event.preventDefault();
    }
}


// Public: Creates an element for editing annotations.
var ddiEditor = exports.ddiEditor = Editor.extend({
    // Public: Creates an instance of the Editor object.
// HTML template for this.element.
    /*ddiEditor.template = [
    '<script> $(function() {$( "#tabs" ).tabs();}); </script><div class="annotator-outer annotator-editor annotator-hide">',
    '  <form class="annotator-widget">',
    '<div id="tabs">',
    '<ul>',
    '<li><a href="#tabs-1">Nunc tincidunt</a></li>',
    '<li><a href="#tabs-2">Proin dolor</a></li>',
    '<li><a href="#tabs-3">Aenean lacinia</a></li>',
    '</ul>',
    '<div id="tabs-1">',
    '    <ul class="annotator-listing"></ul>',
    '    <div class="annotator-controls">',
    '     <a href="#cancel" class="annotator-cancel">' + _t('Cancel') + '</a>',
    '      <a href="#save"',
    '         class="annotator-save annotator-focus">' + _t('Save') + '</a>',
    '    </div>',
    '</div>',
    '</div>',
    '  </form>',
    '</div>'
].join('\n');*/


    constructor: function (options) {
        Widget.call(this, options);

        this.fields = [];
        this.annotation = {};
        var unknowitem = this;

        if (this.options.defaultFields) {

            this.addField({
                type: 'textarea',
                label: _t('Comments') + '\u2026',
                id: 'quote',
                load: function (field, annotation) {
                    $(field).find('#quote').val("' " + annotation.quote + " '" || '');
                    //alert(annotation.quote);
                    $(field).find('#quote').css('background','#DEDEDE');
                }
            });


	    /*// DDI type - PK DDI
	    this.addField({
	    	label: _t('PK DDI'),
	    	type:  'radio',
		name: 'DDIType',
	    	load: function (field, annotation) {
	    	    $(field).find('radio').val(annotation.DDIType || '');
	    	},
	    	submit: function (field, annotation){
	    	    //annotation.DDIType = $(field).find('radio').val();
		    annotation.DDIType = _t('PK_DDI');
	    	} 
	    });

	    // DDI type - Clinical trial
	    this.addField({
	    	label: _t('Clinical Trial'),
	    	type:  'radio',
		name: 'DDIType',
	    	load: function (field, annotation) {
	    	    $(field).find('radio').val(annotation.DDIType || '');
	    	},
	    	submit: function (field, annotation){
	    	    //annotation.DDIType = $(field).find('radio').val();
		    annotation.DDIType = _t('Clinical_Trial');
	    	} 
	    });*/

	    // comment

            this.addField({
                type: 'textarea',
                label: _t('Comments') + '\u2026',
                id:'comment1',
                load: function (field, annotation) {


                    $(field).find('#comment1').val(annotation.text || '');

                },
                submit: function (field, annotation) {
                    annotation.text = $(field).find('#comment1').val();
		    //if (annotation.text == '') {
			//annotation.text = $(field).find('textarea').val()
		    //}
                }
            });

	    //add new fields: drug name, source type
	    this.addField({
	    	label: _t('ddi Drug name') + '\u2026',
	    	type:  'textarea',
            id:'drugName',
	    	load: function (field, annotation) {
	    	    $(field).find('#drugName').val(annotation.drug || '');
	    	},
	    	submit: function (field, annotation){
	    	    annotation.drug = $(field).find('#drugName').val();
	    	}
	    });


            this.addField({
                label:'Drug Role: ',
                type:  'div',
                id: 'qrole',
                load: function (field, annotation) {
                    if($(field).find('#qrole div').length === 0){
                    $(field).find('#qrole')
                        .append('<div /> ' + _t('Drug Role'));
                }}

            });



            unknowitem.addField({
                label: 'Drug Role',
                type:  'div',
                id: 'annotator-field-my-checkbox',
                load: function (field, annotation) {
                    if($(field).find('#annotator-field-my-checkbox input').length === 0) {
                        $(field).find('#annotator-field-my-checkbox')
                            .append('<input type="checkbox" class="checkvalue" id="Object" value="Object" /> ' + 'Object' + '&nbsp');
                        $(field).find('#annotator-field-my-checkbox')
                            .append('<input type="checkbox" class="checkvalue" id="Precipitant" value="Precipitant" /> ' + 'Precipitant' + '<br />');

                    }
                    $('#annotator-field-my-checkbox input').each(function(){ this.checked = false; });
                    $('#annotator-field-my-checkbox input').each(function(){ if(this.value === annotation.drugrole) this.checked = true; });
                    $(field).find('#annotator-field-my-checkbox #Object').on('change',function() {

                        $('#testtext2').hide();
                        $('#testtext1').show("slow");
                    });

                    $(field).find('#annotator-field-my-checkbox #Precipitant').on('change',function() {

                        $('#testtext1').hide();
                        $('#testtext2').show("slow");
                    });
                    $('input[type="checkbox"]').on('change', function () {

                            //alert($('.checkvalue').val());
                            // uncheck sibling checkboxes (checkboxes on the same row)
                            $(this).siblings().prop('checked', false);

                            // uncheck checkboxes in the same column
                            $('div').find('input[type="checkbox"]:eq(' + $(this).index() + ')').not(this).prop('checked', false);

                        });

                    //$(field).find('#annotator-field-1').val(annotation.drug || '');
                },
                submit: function (field, annotation){
                    $.each($("input[class='checkvalue']:checked"), function(){
                        annotation.drugrole = $(this).val();
                    });
                    //annotation.drug = $(field).find('#annotator-field-1').val();
                }
            });

            this.addField({
                type: 'textarea',
                label: _t('Object Options') + '\u2026',
                id: 'testtext1',
                load: function (field, annotation) {
                    //$(field).find('#testtext').val("' " + annotation.quote + " '" || '');
                    //alert(annotation.quote);
                    $(field).find('#testtext1').css('background','#DEDEDE');
                    //if(annotation.objectoptions=="")
                    $(field).find('#testtext1').hide();
                },
                submit: function (field, annotation){
                    if($('#annotator-field-my-checkbox #Object').is(':checked')) {
                        alert($(field).find('#testtext1').val());
                        annotation.objectoptions = $(field).find('#testtext1').val();
                    }
                }
            });


            this.addField({
                type: 'textarea',
                label: _t('Precipitant Options') + '\u2026',
                id: 'testtext2',
                load: function (field, annotation) {
                    //$(field).find('#testtext').val("' " + annotation.quote + " '" || '');
                    //alert(annotation.quote);
                    $(field).find('#testtext2').css('background','#DEDEDE');
                    $(field).find('#testtext2').hide();
                },
                submit: function (field, annotation){
                    if($('#annotator-field-my-checkbox #Precipitant').is(':checked')) {
                        annotation.precipitantoptions = $(field).find('#testtext2').val();
                    }
                }
            });

            this.addField({
                label:'Source Type: ',
                type:  'div',
                id: 'qtype',
                load: function (field, annotation) {
                    if($(field).find('#qtype div').length === 0){
                    $(field).find('#qtype')
                        .append('<div /> ' + _t('Source Type'));
                }}

            });


            this.addField({
                label: _t('Source Type') + '\u2026',
                //values:['Clinical Trial', 'Other'],
                type: 'select',
                id: 'annotator-field-my-selector',
                load: function (field, annotation) {

                    if($(field).find('#annotator-field-my-selector option').length === 0){
                        //$(field).find('#annotator-field-my-selector option').onclick("showobject()");
                        $(field).find('#annotator-field-my-selector')
                            .append($("<option></option>")
                                .attr("value", "Clinical Trial")
                                .text('Clinical Trial'));
                        $(field).find('#annotator-field-my-selector')
                            .append($("<option></option>")
                                .attr("value", "Other")
                                .text('Other'));
                    }
                    $(field).find('#annotator-field-my-selector').val(annotation.sourceType!=null?annotation.sourceType:'Other');
                },
                submit: function (field, annotation){
                    annotation.sourceType = $(field).find('#annotator-field-my-selector').val();
                }
            });



            //   Add a new checkbox element.
            //   editor.addField({
            //     type: 'checkbox',
            //     id: 'annotator-field-my-checkbox',
            //     label: 'Allow anyone to see this annotation',
            //     load: (field, annotation) ->
            //       # Check what state of input should be.
            //       if checked
            //         $(field).find('input').attr('checked', 'checked')
            //       else
            //         $(field).find('input').removeAttr('checked')

            //     submit: (field, annotation) ->
            //       checked = $(field).find('input').is(':checked')
            //       # Do something.
            //   })


	// test end

        }

        var self = this;

        this.element
            .on("submit." + NS, 'form', function (e) {
                self._onFormSubmit(e);
            })
            .on("click." + NS, '.annotator-save', function (e) {
                self._onSaveClick(e);
            })
            .on("click." + NS, '.annotator-cancel', function (e) {
                self._onCancelClick(e);
            })
            .on("mouseover." + NS, '.annotator-cancel', function (e) {
                self._onCancelMouseover(e);
            })
            .on("keydown." + NS, 'textarea', function (e) {
                self._onTextareaKeydown(e);
            });
    },



    destroy: function () {
        this.element.off("." + NS);
        Widget.prototype.destroy.call(this);
    },

    // Public: Show the editor.
    //
    // position - An Object specifying the position in which to show the editor
    //            (optional).
    //
    // Examples
    //
    //   editor.show()
    //   editor.hide()
    //   editor.show({top: '100px', left: '80px'})
    //
    // Returns nothing.
    show: function (position) {
        if (typeof position !== 'undefined' && position !== null) {
            this.element.css({
                top: position.top,
                left: position.left
            });
        }

        this.element
            .find('.annotator-save')
            .addClass(this.classes.focus);

        Widget.prototype.show.call(this);

        // give main textarea focus
        this.element.find(":input:first").focus();

        this._setupDraggables();
    },

    // Public: Load an annotation into the editor and display it.
    //
    // annotation - An annotation Object to display for editing.
    // position - An Object specifying the position in which to show the editor
    //            (optional).
    //
    // Returns a Promise that is resolved when the editor is submitted, or
    // rejected if editing is cancelled.
    load: function (annotation, position) {
        this.annotation = annotation;

        for (var i = 0, len = this.fields.length; i < len; i++) {
            var field = this.fields[i];
            field.load(field.element, this.annotation);
        }

        var self = this;
        return new Promise(function (resolve, reject) {
            self.dfd = {resolve: resolve, reject: reject};
            self.show(position);
        });
    },

    // Public: Submits the editor and saves any changes made to the annotation.
    //
    // Returns nothing.
    submit: function () {


	//alert('ddieditor.js - submit: ' + _attris(this.fields))
	

        for (var i = 0, len = this.fields.length; i < len; i++) {
            var field = this.fields[i];

	    //if (i<2){
		//alert('ddieditor.js - submit: ' + _attris(field.element));

		//alert('ddieditor.js - submit: [id:' +field.id+',name:' + field.name +',label:' + field.label + ',type:' + field.type + ',element:' + field.element.value + ']');
	    //}
	    
            field.submit(field.element, this.annotation);
        }
        if (typeof this.dfd !== 'undefined' && this.dfd !== null) {
            this.dfd.resolve();
        }
        this.hide();
    },

    // Public: Cancels the editing process, discarding any edits made to the
    // annotation.
    //
    // Returns itself.
    cancel: function () {
        if (typeof this.dfd !== 'undefined' && this.dfd !== null) {
            this.dfd.reject('editing cancelled');
        }
        this.hide();
    },

    // Public: Adds an additional form field to the editor. Callbacks can be
    // provided to update the view and anotations on load and submission.
    //
    // options - An options Object. Options are as follows:
    //           id     - A unique id for the form element will also be set as
    //                    the "for" attribute of a label if there is one.
    //                    (default: "annotator-field-{number}")
    //           type   - Input type String. One of "input", "textarea",
    //                    "checkbox", "select" (default: "input")
    //           label  - Label to display either in a label Element or as
    //                    placeholder text depending on the type. (default: "")
    //           load   - Callback Function called when the editor is loaded
    //                    with a new annotation. Receives the field <li> element
    //                    and the annotation to be loaded.
    //           submit - Callback Function called when the editor is submitted.
    //                    Receives the field <li> element and the annotation to
    //                    be updated.
    //
    // Examples

    //   # Add a new input element.
    //   editor.addField({
    //     label: "Tags",
    //
    //     # This is called when the editor is loaded use it to update your
    //     # input.
    //     load: (field, annotation) ->
    //       # Do something with the annotation.
    //       value = getTagString(annotation.tags)
    //       $(field).find('input').val(value)
    //
    //     # This is called when the editor is submitted use it to retrieve data
    //     # from your input and save it to the annotation.
    //     submit: (field, annotation) ->
    //       value = $(field).find('input').val()
    //       annotation.tags = getTagsFromString(value)
    //   })
    //
    //   # Add a new checkbox element.
    //   editor.addField({
    //     type: 'checkbox',
    //     id: 'annotator-field-my-checkbox',
    //     label: 'Allow anyone to see this annotation',
    //     load: (field, annotation) ->
    //       # Check what state of input should be.
    //       if checked
    //         $(field).find('input').attr('checked', 'checked')
    //       else
    //         $(field).find('input').removeAttr('checked')

    //     submit: (field, annotation) ->
    //       checked = $(field).find('input').is(':checked')
    //       # Do something.
    //   })
    //
    // Returns the created <li> Element.
    addField: function (options) {
        var field = $.extend({
            id: 'annotator-field-' + id(),
	    name: '',
            type: 'input',
            label: '',
            load: function () {},
            submit: function () {}
        }, options);

        var input = null,
        element = $('<li class="annotator-item" />');


        field.element = element[0];

	// add type radio button

        if (field.type === 'textarea') {
            input = $('<textarea />');
        } else if (field.type === 'checkbox') {
            input = $('<input type="checkbox" />');
        } else if (field.type === 'input') {
            input = $('<input />');
        } else if (field.type === 'select') {
            input = $('<select />');
        } else if (field.type === 'div') {
            input = $('<div value="source" />');
        } else if (field.type === 'radio') {
	    input = $('<input type="radio" name="'+field.name+'"/>');
	}

        element.append(input);

        input.attr({
            id: field.id,
            placeholder: field.label
        });


        if (field.type === 'div') {
            input.attr({

                html: field.label
            });
        }

        if (field.type === 'checkbox') {
            element.addClass('annotator-checkbox');
            element.append($('<label />', {
                'for': field.id,
                'html': field.label
            }));
        }

        if (field.name === 'DDIType') {
            // element.addClass('annotator-radio');
	    //if (field.label == 'PK DDI' || field.label == 'Clinical Trial')
	    //alert('radio name:' + field.name);
	    //field.name = 'DDIType';
	    
            element.append($('<label />', {
                'for': field.id,
                'html': field.label
            }));
        }

        this.element.find('ul:first').append(element);
        this.fields.push(field);

        return field.element;
    },

    checkOrientation: function () {
        Widget.prototype.checkOrientation.call(this);

        var list = this.element.find('ul').first(),
            controls = this.element.find('.annotator-controls');

        if (this.element.hasClass(this.classes.invert.y)) {
            controls.insertBefore(list);
        } else if (controls.is(':first-child')) {
            controls.insertAfter(list);
        }

        return this;
    },

    // Event callback: called when a user clicks the editor form (by pressing
    // return, for example).
    //
    // Returns nothing
    _onFormSubmit: function (event) {
        preventEventDefault(event);
        this.submit();
    },

    // Event callback: called when a user clicks the editor's save button.
    //
    // Returns nothing
    _onSaveClick: function (event) {
        preventEventDefault(event);
        this.submit();
    },

    // Event callback: called when a user clicks the editor's cancel button.
    //
    // Returns nothing
    _onCancelClick: function (event) {
        preventEventDefault(event);
        this.cancel();
    },

    // Event callback: called when a user mouses over the editor's cancel
    // button.
    //
    // Returns nothing
    _onCancelMouseover: function () {
        this.element
            .find('.' + this.classes.focus)
            .removeClass(this.classes.focus);
    },

    // Event callback: listens for the following special keypresses.
    // - escape: Hides the editor
    // - enter:  Submits the editor
    //
    // event - A keydown Event object.
    //
    // Returns nothing
    _onTextareaKeydown: function (event) {
        if (event.which === 27) {
            // "Escape" key => abort.
            this.cancel();
        } else if (event.which === 13 && !event.shiftKey) {
            // If "return" was pressed without the shift key, we're done.
            this.submit();
        }
    },

    // Sets up mouse events for resizing and dragging the editor window.
    //
    // Returns nothing.
    _setupDraggables: function () {
        if (typeof this._resizer !== 'undefined' && this._resizer !== null) {
            this._resizer.destroy();
        }
        if (typeof this._mover !== 'undefined' && this._mover !== null) {
            this._mover.destroy();
        }

        this.element.find('.annotator-resize').remove();

        // Find the first/last item element depending on orientation
        var cornerItem;
        if (this.element.hasClass(this.classes.invert.y)) {
            cornerItem = this.element.find('.annotator-item:last');
        } else {
            cornerItem = this.element.find('.annotator-item:first');
        }

        if (cornerItem) {
            $('<span class="annotator-resize"></span>').appendTo(cornerItem);
        }

        var controls = this.element.find('.annotator-controls')[0],
            textarea = this.element.find('textarea:first')[0],
            resizeHandle = this.element.find('.annotator-resize')[0],
            self = this;

        this._resizer = resizer(textarea, resizeHandle, {
            invertedX: function () {
                return self.element.hasClass(self.classes.invert.x);
            },
            invertedY: function () {
                return self.element.hasClass(self.classes.invert.y);
            }
        });

        this._mover = mover(this.element[0], controls);
    }
});



// dragTracker is a function which allows a callback to track changes made to
// the position of a draggable "handle" element.
//
// handle - A DOM element to make draggable
// callback - Callback function
//
// Callback arguments:
//
// delta - An Object with two properties, "x" and "y", denoting the amount the
//         mouse has moved since the last (tracked) call.
//
// Callback returns: Boolean indicating whether to track the last movement. If
// the movement is not tracked, then the amount the mouse has moved will be
// accumulated and passed to the next mousemove event.
//
var dragTracker = exports.dragTracker = function dragTracker(handle, callback) {
    var lastPos = null,
        throttled = false;

    // Event handler for mousemove
    function mouseMove(e) {
        if (throttled || lastPos === null) {
            return;
        }

        var delta = {
            y: e.pageY - lastPos.top,
            x: e.pageX - lastPos.left
        };

        var trackLastMove = true;
        // The callback function can return false to indicate that the tracker
        // shouldn't keep updating the last position. This can be used to
        // implement "walls" beyond which (for example) resizing has no effect.
        if (typeof callback === 'function') {
            trackLastMove = callback(delta);
        }

        if (trackLastMove !== false) {
            lastPos = {
                top: e.pageY,
                left: e.pageX
            };
        }

        // Throttle repeated mousemove events
        throttled = true;
        setTimeout(function () { throttled = false; }, 1000 / 60);
    }


    // Event handler for mouseup
    function mouseUp() {
        lastPos = null;
        $(handle.ownerDocument)
            .off('mouseup', mouseUp)
            .off('mousemove', mouseMove);
    }

    // Event handler for mousedown -- starts drag tracking
    function mouseDown(e) {
        if (e.target !== handle) {
            return;
        }

        lastPos = {
            top: e.pageY,
            left: e.pageX
        };

        $(handle.ownerDocument)
            .on('mouseup', mouseUp)
            .on('mousemove', mouseMove);

        e.preventDefault();
    }

    // Public: turn off drag tracking for this dragTracker object.
    function destroy() {
        $(handle).off('mousedown', mouseDown);
    }

    $(handle).on('mousedown', mouseDown);

    return {destroy: destroy};
};


// resizer is a component that uses a dragTracker under the hood to track the
// dragging of a handle element, using that motion to resize another element.
//
// element - DOM Element to resize
// handle - DOM Element to use as a resize handle
// options - Object of options.
//
// Available options:
//
// invertedX - If this option is defined as a function, and that function
//             returns a truthy value, the horizontal sense of the drag will be
//             inverted. Useful if the drag handle is at the left of the
//             element, and so dragging left means "grow the element"
// invertedY - If this option is defined as a function, and that function
//             returns a truthy value, the vertical sense of the drag will be
//             inverted. Useful if the drag handle is at the bottom of the
//             element, and so dragging down means "grow the element"
var resizer = exports.resizer = function resizer(element, handle, options) {
    var $el = $(element);
    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    // Translate the delta supplied by dragTracker into a delta that takes
    // account of the invertedX and invertedY callbacks if defined.
    function translate(delta) {
        var directionX = 1,
            directionY = -1;

        if (typeof options.invertedX === 'function' && options.invertedX()) {
            directionX = -1;
        }
        if (typeof options.invertedY === 'function' && options.invertedY()) {
            directionY = 1;
        }

        return {
            x: delta.x * directionX,
            y: delta.y * directionY
        };
    }

    // Callback for dragTracker
    function resize(delta) {
        var height = $el.height(),
            width = $el.width(),
            translated = translate(delta);

        if (Math.abs(translated.x) > 0) {
            $el.width(width + translated.x);
        }
        if (Math.abs(translated.y) > 0) {
            $el.height(height + translated.y);
        }

        // Did the element dimensions actually change? If not, then we've
        // reached the minimum size, and we shouldn't track
        var didChange = ($el.height() !== height || $el.width() !== width);
        return didChange;
    }

    // We return the dragTracker object in order to expose its methods.
    return dragTracker(handle, resize);
};


// mover is a component that uses a dragTracker under the hood to track the
// dragging of a handle element, using that motion to move another element.
//
// element - DOM Element to move
// handle - DOM Element to use as a move handle
//
var mover = exports.mover = function mover(element, handle) {
    function move(delta) {
        $(element).css({
            top: parseInt($(element).css('top'), 10) + delta.y,
            left: parseInt($(element).css('left'), 10) + delta.x
        });
    }

    // We return the dragTracker object in order to expose its methods.
    return dragTracker(handle, move);
};
