"use strict";

var Util = require('./util'),
    $ = Util.$;

var INFO = 'info',
    SUCCESS = 'success',
    ERROR = 'error';

// BannerNotification is simple notification system that can be used to display
// information, warnings and errors to the user.
//
// message - The notification message text
// severity - The severity of the message (one of Notification.INFO,
//            Notification.SUCCESS, or Notification.ERROR)
//
function BannerNotification(message, severity) {
    if (typeof severity == 'undefined' || severity === null) {
        severity = INFO;
    }

    this.element = $(BannerNotification.template)[0];
    this.severity = severity;
    this.closed = false;

    $(this.element)
        .addClass(BannerNotification.classes.show)
        .addClass(BannerNotification.classes[this.severity])
        .html(Util.escapeHtml(message || ""))
        .appendTo(Util.getGlobal().document.body);

    var self = this;

    $(this.element).on('click', function () { self.close(); });

    // Hide the notification after 5s
    setTimeout(function () { self.close(); }, 5000);
}

// Public: Close the notification.
//
// Returns the instance.
BannerNotification.prototype.close = function () {
    if (this.closed) {
        return;
    }

    this.closed = true;

    $(this.element)
        .removeClass(BannerNotification.classes.show)
        .removeClass(BannerNotification.classes[this.severity]);

    // The removal of the above classes triggers a 400ms ease-out transition, so
    // we can dispose the element from the DOM after 500ms.
    var self = this;
    setTimeout(function () {
        $(self.element).remove();
    }, 500);
};

BannerNotification.template = "<div class='annotator-notice'></div>";

BannerNotification.classes = {
    show: "annotator-notice-show",
    info: "annotator-notice-info",
    success: "annotator-notice-success",
    error: "annotator-notice-error"
};


exports.Banner = function () {
    return {
        create: function (message, severity) {
            return new BannerNotification(message, severity);
        }
    };
};

// Constants for controlling the display of the notification. Each constant
// adds a different class to the Notification#element.
exports.INFO = INFO;
exports.SUCCESS = SUCCESS;
exports.ERROR = ERROR;
