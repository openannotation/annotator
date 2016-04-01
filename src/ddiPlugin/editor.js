"use strict";
var Widget = require('./../ui/widget').Widget;
var util = require('../util');
var Editor = require('../drugPlugin/editor').Editor;
var Template = require('./template').Template;

var $ = util.$;
var _t = util.gettext;
var Promise = util.Promise;
var NS = "annotator-editor";

// bring storage in
var HttpStorage = require('../storage').HttpStorage;

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

    constructor: function (options) {
        Widget.call(this, options);
        var editorSelf = this;
        this.fields = [];
        this.annotation = {};

        //console.log("[INFO] ddi - editor - constructor");

        if (this.options.defaultFields) {

            //quote content + load and submit all content

            this.addField({
                type: 'div',
                label: _t('Comments') + '\u2026',
                id: 'quote',
                load: function (field, annotation,annotations) {

                    //var annList = annotations.slice();
                    //console.log(annList[0].quote);
                    //var now = annList.splice(0, annotations.options.chunkSize);

                    $('#quote').empty();
                    var quoteobject = $("<div id='quotearea'/>");
                    $('#quote').append(quoteobject);
                    $('#quotearea').html(annotation.quote || '');
                    $('#Drug1 option').remove();
                    $('#Drug2 option').remove();
                    var flag = 0;
                    console.log(annotations.length);
                    var anns = annotations.slice();
                    //console.log("(1):"+anns[0].quote);
                    var quoteobject = $('#quotearea');
                    var quotecontent = $('#quotearea').html();
                    //console.log(quotecontent);
                    var index = 0;
                    var list = [];
                    //filter out duplicates
                    for (var i = 0, len = anns.length; i < len; i++) {
                        if ((anns[i].annotationType == "DrugMention") && (list.indexOf(anns[i].quote) < 0)) {
                            list.push(anns[i].quote);
                            //console.log(anns[i].quote);
                        }
                    }
                    for (var i = 0, len = list.length; i < len; i++) {
                        if (quotecontent.indexOf(list[i]) >= 0) {
                            index++;
                            //quotecontent.split(list[i]).join("<span class='highlightdrug'>"+list[i]+"<sup>"+index+"</sup></span>");
                            //console.log(quotecontent);
                            quotecontent = quotecontent.replace(list[i], "<span class='highlightdrug'>" + list[i] + "</span>");
                            $('#Drug1').append($('<option>', {
                                value: list[i],
                                text: list[i]
                            }));
                            $('#Drug2').append($('<option>', {
                                value: list[i],
                                text: list[i]
                            }));
                            flag = flag + 1;
                        }
                    }
                    quoteobject.html(quotecontent);
                    /*$('[name="annotator-hl"]').each(function(index){
                     //alert(annotation.quote);
                     if(annotation.quote.indexOf($('[name="annotator-hl"]:eq('+index+')').text())>=0) {

                     //console.log($('[name="annotator-hl"]:eq('+index+')').text());
                     var tempdrug = $('[name="annotator-hl"]:eq(' + index + ')').text();
                     //var quoteobject = document.getElementById('quote');
                     console.log(tempdrug);
                     var quotecontent = quoteobject.html();
                     //console.log( "1"+$('#quotearea').val());
                     //console.log( "2"+quoteobject.html());
                     quotecontent = quotecontent.replace(tempdrug,"<span class='highlightdrug'>"+tempdrug+"</span>");
                     quoteobject.html(quotecontent);
                     console.log(quotecontent);
                     $('#Drug1').append($('<option>', {
                     value: tempdrug,
                     text: tempdrug
                     }));
                     $('#Drug2').append($('<option>', {
                     value: tempdrug,
                     text: tempdrug
                     }));
                     flag = flag + 1;
                     }
                     });*/
                    if (flag < 2) {
                        //if(flag){
                        alert("Should highlight at least two drugs.");
                        editorSelf.cancel();
                        $('.btn-success').click();
                    }
                    if (annotation.Drug1 != "") {
                        var quotestring = quoteobject.html();
                        quotestring = quotestring.replace(annotation.Drug1, "<span class='selecteddrug'>" + annotation.Drug1 + "</span>");
                        quoteobject.html(quotestring);
                        //console.log(quotestring);
                    }
                    if (annotation.Drug2 != "") {
                        var quotestring = quoteobject.html();
                        quotestring = quotestring.replace(annotation.Drug2, "<span class='selecteddrug'>" + annotation.Drug2 + "</span>");
                        quoteobject.html(quotestring);
                        //console.log(quotestring);
                    }

                    $(field).find('#quote').css('background', '#EDEDED');

                    /*$(field).find('#DDI').on('selected',function() {
                     $('#ddisection').show("slow");
                     });
                     $(field).find('#clinical').on('selected',function() {
                     $('#ddisection').hide();
                     });*/
                    console.debug("annotation.assertion_type:" + annotation.assertion_type);
                    if (annotation.assertion_type == "DDI clinical trial") {
                        $('#altersection').show();
                        $('.moreinfo').show();

                    } else {
                        $('#altersection').hide();
                    }
                    var signal = 1;
                    $('#Number_participants').val(annotation.Number_participants);
                    $('#Duration_object').val(annotation.Duration_object);
                    $('#Duration_precipitant').val(annotation.Duration_precipitant);
                    $('#DoseMG_object').val(annotation.DoseMG_object);
                    $('#DoseMG_precipitant').val(annotation.DoseMG_precipitant);
                    $('#Auc').val(annotation.Aucval);
                    $('#Cli').val(annotation.Clval);
                    $('#cmax').val(annotation.cmaxval);
                    $('#cmin').val(annotation.cminval);
                    $('#t12').val(annotation.t12);

                    $("#FormulationP > option").each(function () {
                        if (this.value === annotation.FormulationP) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#FormulationP > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#FormulationO > option").each(function () {
                        if (this.value === annotation.FormulationO) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#FormulationO > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#RegimentsP > option").each(function () {
                        if (this.value === annotation.RegimentsP) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#RegimentsP > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#RegimentsO > option").each(function () {
                        if (this.value === annotation.RegimentsO) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#RegimentsO > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#AucType > option").each(function () {
                        if (this.value === annotation.AucType) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#AucType > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#AucDirection > option").each(function () {
                        if (this.value === annotation.AucDirection) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#AucDirection > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#ClType > option").each(function () {
                        if (this.value === annotation.ClType) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#ClType > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#ClDirection > option").each(function () {
                        if (this.value === annotation.ClDirection) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#ClDirection > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#cmaxType > option").each(function () {
                        if (this.value === annotation.cmaxType) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#cmaxType > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#cmaxDirection > option").each(function () {
                        if (this.value === annotation.cmaxDirection) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#cmaxDirection > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#cminType > option").each(function () {
                        if (this.value === annotation.cminType) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#cminType > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#cminDirection > option").each(function () {
                        if (this.value === annotation.cminDirection) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#cminDirection > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#t12Type > option").each(function () {
                        if (this.value === annotation.t12Type) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#t12Type > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $("#t12Direction > option").each(function () {
                        if (this.value === annotation.t12Direction) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#t12Direction > option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }


                    //load all content
                    $("#Drug1 > option").each(function () {
                        if (this.value === annotation.Drug1) $(this).attr('selected', true);
                    });
                    $('#Drug2 > option').each(function () {
                        if (this.value === annotation.Drug2) $(this).attr('selected', true);
                    });
                    $('#assertion_type option').each(function () {
                        if (this.value === annotation.assertion_type) {
                            $(this).attr('selected', true);
                            signal = 0;
                        }
                    });
                    if (signal == 1) {
                        $('#assertion_type option')[0].selected = "selected";
                    } else {
                        signal = 1;
                    }
                    $('.Type1').each(function () {
                        if (this.value === annotation.Type1) this.checked = true; else this.checked = false;
                    });
                    $('.Role1').each(function () {
                        if (this.value === annotation.Role1) this.checked = true; else this.checked = false;
                    });
                    $('.Type2').each(function () {
                        if (this.value === annotation.Type2) this.checked = true; else this.checked = false;
                    });
                    $('.Role2').each(function () {
                        if (this.value === annotation.Role2) this.checked = true; else this.checked = false;
                    });
                    $('.Modality').each(function () {
                        if (this.value === annotation.Modality) this.checked = true; else this.checked = false;
                    });
                    $('.Evidence_modality').each(function () {
                        if (this.value === annotation.Evidence_modality) this.checked = true; else this.checked = false;
                    });
                    $('#Comment').each(function () {
                        this.value = annotation.Comment;
                    });
                    if (annotation.assertion_type == "DDI clinical trial") {
                        var object = $("#Drug1 option:selected").text();
                        $("#objectinalter").html("Object: " + object);
                        var precipt = $("#Drug2 option:selected").text();
                        $("#preciptinalter").html("Precipt: " + precipt);
                        $("#back").hide();
                        $("#forward").show();
                        var modal = $("#Modality:checked").val();
                        $("#modalityinalter").html("Modality: " + modal);
                        var evid = $("#Evidence_modality:checked").val();
                        $("#evidenceinalter").html("Evidence: " + evid);
                    }else{
                        $("#forward").hide();
                    }
                    $('#firstsection').show();
                    $('#altersection').hide();
                },
                submit:function (field, annotation) {
                    if($('#Drug1 option:selected').text()==$('#Drug2 option:selected').text()){
                        //if(flag){
                        alert("Should highlight two different drugs.");
                        editorSelf.cancel();
                        //$('.btn-success').click();
                    }
                    annotation.Drug1 = $('#Drug1 option:selected').text();
                    annotation.Drug2 = $('#Drug2 option:selected').text();
                    annotation.Type1 = $('#Type1:checked').val();
                    annotation.Type2 = $('#Type2:checked').val();
                    annotation.Role1 = "object";
                    annotation.Role2 = "precipitant";
                    annotation.assertion_type = $('#assertion_type option:selected').text();
                    annotation.Modality = $('#Modality:checked').val();
                    annotation.Evidence_modality = $('#Evidence_modality:checked').val();
                    annotation.Comment = $('#Comment').val();
                    annotation.annotationType = "DDI";
                    if(annotation.assertion_type=="DDI clinical trial")
                    {
                        annotation.Number_participants = $('#Number_participants').val();
                        annotation.FormulationP = $('#FormulationP option:selected').text();
                        annotation.FormulationO = $('#FormulationO option:selected').text();
                        annotation.DoseMG_precipitant = $('#DoseMG_precipitant').val();
                        annotation.DoseMG_object = $('#DoseMG_object').val();
                        annotation.Duration_precipitant = $('#Duration_precipitant').val();
                        annotation.Duration_object = $('#Duration_object').val();
                        annotation.RegimentsP = $('#RegimentsP option:selected').text();
                        annotation.RegimentsO = $('#RegimentsO option:selected').text();
                        annotation.Aucval = $('#Auc').val();
                        annotation.AucType = $('#AucType option:selected').text();
                        annotation.AucDirection = $('#AucDirection option:selected').text();
                        annotation.Clval = $('#Cli').val();
                        annotation.ClType = $('#ClType option:selected').text();
                        annotation.ClDirection = $('#ClDirection option:selected').text();
                        annotation.cmaxval = $('#cmax').val();
                        annotation.cmaxType = $('#cmaxType option:selected').text();
                        annotation.cmaxDirection = $('#cmaxDirection option:selected').text();
                        annotation.cminval = $('#cmin').val();
                        annotation.cminType = $('#cminType option:selected').text();
                        annotation.cminDirection = $('#cminDirection option:selected').text();
                        annotation.t12 = $('#t12').val();
                        annotation.t12Type = $('#t12Type option:selected').text();
                        annotation.t12Direction = $('#t12Direction option:selected').text();
                    }
                }
            });

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
                //top: position.top,
                //left: position.left
                bottom:50,
                right:100
            });
            $( window ).resize(function() {
                $( "body" ).css('height','600px');
            });

            //console.log(window.screen.height);
            //console.log(window.screen.availHeight);
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
    load: function (position, annotation) {
        this.annotation = annotation;
        if(this.annotation.quote.length>1600){
            alert("[INFO] Exceeding max lengh of text 1600!");
            $('.btn-success').click();
            this.cancel();

        }
        var annotations;
        if(getURLParameter("sourceURL")==null)
            var sourceURL = getURLParameter("file").trim();
        else
            var sourceURL = getURLParameter("sourceURL").trim();
        var source = sourceURL.replace(/[\/\\\-\:\.]/g, "")
        var email = getURLParameter("email");

        var queryObj = JSON.parse('{"uri":"'+source+'","email":"'+email+'"}');

        var annhost = config.annotator.host;
        //var annport = config.store.port;

        // call apache for request annotator store
        var queryOptStr = '{"emulateHTTP":false,"emulateJSON":false,"headers":{},"prefix":"http://' + annhost + '/annotatorstore","urls":{"create":"/annotations","update":"/annotations/{id}","destroy":"/annotations/{id}","search":"/search"}}';
        console.log(queryOptStr);

        var queryOptions = JSON.parse(queryOptStr);

        //var queryOptions = JSON.parse('{"emulateHTTP":false,"emulateJSON":false,"headers":{},"prefix":"http://localhost:5000","urls":{"create":"/annotations","update":"/annotations/{id}","destroy":"/annotations/{id}","search":"/search"}}');

        var storage = new HttpStorage(queryOptions);
        //console.log("ddieditor.js - constructor - load:" + JSON.stringify(app.annotations));
        //console.log("editor call storage");
        var self = this;
        storage.query(queryObj)
            .then(function(data){
                //console.log("editor call results2:" + JSON.stringify(data.results));
                annotations = data.results;
                for (var i = 0, len = self.fields.length; i < len; i++) {
                    var field = self.fields[i];
                    field.load(field.element, self.annotation,annotations);
                    //field.load(field.element, this.annotation, this.annotations);
                }
            });
        //console.log(r.length);



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
        for (var i = 0, len = this.fields.length; i < len; i++) {
            var field = this.fields[i];

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
            type: 'input',
            label: '',
            load: function () {},
            submit: function () {}
        }, options);

        var input = null,
            element = $('<li class="annotator-item" />');


        field.element = element[0];

        if (field.type === 'textarea') {
            input = $('<textarea />');
        } else if (field.type === 'checkbox') {
            input = $('<input type="checkbox" />');
        } else if (field.type === 'input') {
            input = $('<input />');
        } else if (field.type === 'select') {
            input = $('<select />');
        } else if (field.type === 'div') {
            input = $('<div class = "quoteborder" />');
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

        this.element.find('ul:first').append(element);
        this.fields.push(field);

        return field.element;
    },

    checkOrientation: function () {
        Widget.prototype.checkOrientation.call(this);

        var list = this.element.find('ul').first();
        var controls = this.element.find('.annotator-controls1');
        var tabs = this.element.find('#tabs');
        controls.insertAfter(tabs);
        /*if (this.element.hasClass(this.classes.invert.y)) {
         controls.insertBefore(list);
         } else if (controls.is(':first-child')) {
         controls.insertAfter(list);
         }*/

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

        /*if (cornerItem) {
            $('<span class="annotator-resize"></span>').appendTo(cornerItem);
        }*/

        //var controls = this.element.find('.annotator-controls')[0];
 /*        var   textarea = this.element.find('textarea:first')[0],
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
*/
        //this._mover = mover(this.element[0], controls);
    }
});
/*
 //handlebars test
 var handlebars = require('handlebars');
 var fs = require('fs');

 var fooJson = {
 tags: ['express', 'node', 'javascript']
 }

 // get your data into a variable
 //var fooJson = require('path/to/foo.json');

 // read the file and use the callback to render
 fs.readFile('handlebars-example.hbs', function(err, data){
 if (!err) {
 // make the buffer into a string
 var source = data.toString();
 // call the render function
 renderToString(source, fooJson);
 //alert(testhandle);
 } else {
 // handle file read error
 }
 });

 // this will be called after the file is read
 function renderToString(source, data) {
 var template = handlebars.compile(source);
 var outputString = template(data);
 //alert(outputString);
 return outputString;
 }
 */
/*$.ajax({
 url: "template.html", dataType: "html"
 }).done(function( responseHtml ) {
 $("#mydiv").html(responseHtml);
 console.log(responseHtml);
 });*/

//var Handlebars = require("handlebars");
//var source   = $("#entry-template").html();
//var template = Handlebars.compile(source);
ddiEditor.template = Template.content;





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
            //y: e.pageY - lastPos.top,
            //x: e.pageX - lastPos.left
            y:200,
            x:200
        };
        //console.log(e.pageX);

        var trackLastMove = true;
        // The callback function can return false to indicate that the tracker
        // shouldn't keep updating the last position. This can be used to
        // implement "walls" beyond which (for example) resizing has no effect.
        if (typeof callback === 'function') {
            trackLastMove = callback(delta);
        }

        if (trackLastMove !== false) {
            lastPos = {
                //top: e.pageY,
                //left: e.pageX
                top:200,
                left:200
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
            //top: e.pageY,
            //left: e.pageX
            top:200,
            left:200
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
