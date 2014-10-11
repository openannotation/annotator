"use strict";

var Util = require('./util'),
    $ = Util.$;

var INFO = 'info',
    SUCCESS = 'success',
    ERROR = 'error';

// BannerNotifier is simple notifier system that can be used to display
// information, warnings and errors to the user.
//
// message - The notifier message text
// severity - The severity of the message (one of Notifier.INFO,
//            Notifier.SUCCESS, or Notifier.ERROR)
//
function BannerNotifier(message, severity) {
    if (typeof severity === 'undefined' || severity === null) {
        severity = INFO;
    }

    this.element = $(BannerNotifier.template)[0];
    this.severity = severity;
    this.closed = false;

    $(this.element)
        .addClass(BannerNotifier.classes.show)
        .addClass(BannerNotifier.classes[this.severity])
        .html(Util.escapeHtml(message || ""))
        .appendTo(Util.getGlobal().document.body);

    var self = this;

    $(this.element).on('click', function () { self.close(); });

    // Hide the notifier after 5s
    setTimeout(function () { self.close(); }, 5000);
}

// Public: Close the notifier.
//
// Returns the instance.
BannerNotifier.prototype.close = function () {
    if (this.closed) {
        return;
    }

    this.closed = true;

    $(this.element)
        .removeClass(BannerNotifier.classes.show)
        .removeClass(BannerNotifier.classes[this.severity]);

    // The removal of the above classes triggers a 400ms ease-out transition, so
    // we can dispose the element from the DOM after 500ms.
    var self = this;
    setTimeout(function () {
        $(self.element).remove();
    }, 500);
};

BannerNotifier.template = "<div class='annotator-notice'></div>";

BannerNotifier.classes = {
    show: "annotator-notice-show",
    info: "annotator-notice-info",
    success: "annotator-notice-success",
    error: "annotator-notice-error"
};


exports.Banner = function () {
    return {
        show: function (message, severity) {
            return new BannerNotifier(message, severity);
        }
    };
};

// Constants for controlling the display of the notifier. Each constant
// adds a different class to the Notifier#element.
exports.INFO = INFO;
exports.SUCCESS = SUCCESS;
exports.ERROR = ERROR;
