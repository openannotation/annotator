"use strict";

var extend = require('backbone-extend-standalone');

var util = require('../util');
var $ = util.$;


// Public: Base class for the Editor and Viewer elements. Contains methods that
// are shared between the two.
function Widget(options) {
    this.element = $(this.constructor.template);
    this.classes = $.extend({}, Widget.classes, this.constructor.classes);
    this.options = $.extend(
      {},
      Widget.options,
      this.constructor.options,
      options
    );
    this.extensionsInstalled = false;
}

// Public: Destroy the Widget, unbinding all events and removing the element.
//
// Returns nothing.
Widget.prototype.destroy = function () {
    this.element.remove();
};

// Executes all given widget-extensions
Widget.prototype.installExtensions = function () {
    if (this.options.extensions) {
        for (var i = 0, len = this.options.extensions.length; i < len; i++) {
            var extension = this.options.extensions[i];
            extension(this);
        }
    }
};

Widget.prototype._maybeInstallExtensions = function () {
    if (!this.extensionsInstalled) {
        this.extensionsInstalled = true;
        this.installExtensions();
    }
};

// Public: Attach the widget to a css selector or element
// Plus do any post-construction install
Widget.prototype.attach = function () {
    this.element.appendTo(this.options.appendTo);
    this._maybeInstallExtensions();
};

// Public: Show the widget.
//
// Returns nothing.
Widget.prototype.show = function () {
    this.element.removeClass(this.classes.hide);

    // invert if necessary
    this.checkOrientation();
};

// Public: Hide the widget.
//
// Returns nothing.
Widget.prototype.hide = function () {
    $(this.element).addClass(this.classes.hide);
};

// Public: Returns true if the widget is currently displayed, false otherwise.
//
// Examples
//
//   widget.show()
//   widget.isShown() # => true
//
//   widget.hide()
//   widget.isShown() # => false
//
// Returns true if the widget is visible.
Widget.prototype.isShown = function () {
    return !$(this.element).hasClass(this.classes.hide);
};

Widget.prototype.checkOrientation = function () {
    this.resetOrientation();

    var $win = $(global),
        $widget = this.element.children(":first"),
        offset = $widget.offset(),
        viewport = {
            top: $win.scrollTop(),
            right: $win.width() + $win.scrollLeft()
        },
        current = {
            top: offset.top,
            right: offset.left + $widget.width()
        };

    if ((current.top - viewport.top) < 0) {
        this.invertY();
    }

    if ((current.right - viewport.right) > 0) {
        this.invertX();
    }

    return this;
};

// Public: Resets orientation of widget on the X & Y axis.
//
// Examples
//
//   widget.resetOrientation() # Widget is original way up.
//
// Returns itself for chaining.
Widget.prototype.resetOrientation = function () {
    this.element
        .removeClass(this.classes.invert.x)
        .removeClass(this.classes.invert.y);
    return this;
};

// Public: Inverts the widget on the X axis.
//
// Examples
//
//   widget.invertX() # Widget is now right aligned.
//
// Returns itself for chaining.
Widget.prototype.invertX = function () {
    this.element.addClass(this.classes.invert.x);
    return this;
};

// Public: Inverts the widget on the Y axis.
//
// Examples
//
//   widget.invertY() # Widget is now upside down.
//
// Returns itself for chaining.
Widget.prototype.invertY = function () {
    this.element.addClass(this.classes.invert.y);
    return this;
};

// Public: Find out whether or not the widget is currently upside down
//
// Returns a boolean: true if the widget is upside down
Widget.prototype.isInvertedY = function () {
    return this.element.hasClass(this.classes.invert.y);
};

// Public: Find out whether or not the widget is currently right aligned
//
// Returns a boolean: true if the widget is right aligned
Widget.prototype.isInvertedX = function () {
    return this.element.hasClass(this.classes.invert.x);
};

// Classes used to alter the widgets state.
Widget.classes = {
    hide: 'annotator-hide',
    invert: {
        x: 'annotator-invert-x',
        y: 'annotator-invert-y'
    }
};

Widget.template = "<div></div>";

// Default options for the widget.
Widget.options = {
    // A CSS selector or Element to append the Widget to.
    appendTo: 'body'
};

Widget.extend = extend;


exports.Widget = Widget;
