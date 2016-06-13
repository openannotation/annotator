"use strict";

var Widget = require('./../ui/widget').Widget,
    util = require('../util');

var $ = util.$;
var _t = util.gettext;

var NS = 'annotator-adderddi';


// Adder shows and hides an annotation adder button that can be clicked on to
// create an annotation.
var ddiAdder = Widget.extend({

    constructor: function (options) {
        Widget.call(this, options);

        this.ignoreMouseup = false;
        this.annotation = null;

        this.onCreate = this.options.onCreate;

        var self = this;
        this.element
            .on("click." + NS, 'button', function (e) {
                self._onClick(e);
            })
            .on("mousedown." + NS, 'button', function (e) {
                self._onMousedown(e);
            });

        this.document = this.element[0].ownerDocument;
        $(this.document.body).on("mouseup." + NS, function (e) {
            self._onMouseup(e);
        });
    },

    destroy: function () {
        this.element.off("." + NS);
        $(this.document.body).off("." + NS);
        Widget.prototype.destroy.call(this);
    },

    // Public: Load an annotation and show the adder.
    //
    // annotation - An annotation Object to load.
    // position - An Object specifying the position in which to show the editor
    //            (optional).
    //
    // If the user clicks on the adder with an annotation loaded, the onCreate
    // handler will be called. In this way, the adder can serve as an
    // intermediary step between making a selection and creating an annotation.
    //
    // Returns nothing.
    load: function (annotation, position) {
        this.annotation = annotation;
        this.show(position);
    },

    // Public: Show the adder.
    //
    // position - An Object specifying the position in which to show the editor
    //            (optional).
    //
    // Examples
    //
    //   adder.show()
    //   adder.hide()
    //   adder.show({top: '100px', left: '80px'})
    //
    // Returns nothing.
    show: function (position) {
        if (typeof position !== 'undefined' && position !== null) {
            this.element.css({
                top: position.top,

                // avoid overlapping with drug mention editor
                left: position.left + 35
            });
        }
        Widget.prototype.show.call(this);
    },

    // Event callback: called when the mouse button is depressed on the adder.
    //
    // event - A mousedown Event object
    //
    // Returns nothing.
    _onMousedown: function (event) {
        // Do nothing for right-clicks, middle-clicks, etc.
        if (event.which > 1) {
            return;
        }

        event.preventDefault();
        // Prevent the selection code from firing when the mouse button is
        // released
        this.ignoreMouseup = true;
    },

    // Event callback: called when the mouse button is released
    //
    // event - A mouseup Event object
    //
    // Returns nothing.
    _onMouseup: function (event) {
        // Do nothing for right-clicks, middle-clicks, etc.
        if (event.which > 1) {
            return;
        }

        // Prevent the selection code from firing when the ignoreMouseup flag is
        // set
        if (this.ignoreMouseup) {
            event.stopImmediatePropagation();
        }
    },

    // Event callback: called when the adder is clicked. The click event is used
    // as well as the mousedown so that we get the :active state on the adder
    // when clicked.
    //
    // event - A mousedown Event object
    //
    // Returns nothing.
    _onClick: function (event) {
        // Do nothing for right-clicks, middle-clicks, etc.

        if (event.which > 1) {
            return;
        }

        event.preventDefault();

        console.log("[DEBUG] ddiadder - hide hl and ddi");

        // Hide the adder
        this.hide();
        // Hide drug highlight dder
        // $('.annotator-adderhl').hide();
        $('.annotator-adderhl').removeClass().addClass('annotator-adderhl annotator-hide');

        this.ignoreMouseup = false;

        // Create a new annotation

        if (this.annotation !== null && typeof this.onCreate === 'function') {
            this.annotation.annotationType = "DDI";
            this.onCreate(this.annotation, event);
        }
    }
});

// from hypothesis
// Guest.prototype.html = jQuery.extend({}, Annotator.prototype.html, {
//   adder: '<div class="annotator-adder">\n  <button class="h-icon-insert-comment" data-action="comment" title="New Note"></button>\n  <button class="h-icon-border-color" data-action="highlight" title="Highlight"></button>\n</div>'
// });

ddiAdder.template = [
    '<div class="annotator-adderddi annotator-hide">',
    '  <button type="button" title="DDI" onclick="showright(),editorload()">' + _t('Annotate') + '</button>',
    '</div>'
].join('\n');

// Configuration options
ddiAdder.options = {
    // Callback, called when the user clicks the adder when an
    // annotation is loaded.
    onCreate: null
};

exports.ddiAdder = ddiAdder;

