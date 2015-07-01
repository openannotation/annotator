/*package annotator.notifier */

"use strict";

var util = require('./util');
var $ = util.$;

var INFO = 'info',
    SUCCESS = 'success',
    ERROR = 'error';

var bannerTemplate = "<div class='annotator-notice'></div>";
var bannerClasses = {
    show: "annotator-notice-show",
    info: "annotator-notice-info",
    success: "annotator-notice-success",
    error: "annotator-notice-error"
};


/**
 * function:: banner(message[, severity=notification.INFO])
 *
 * Creates a user-visible banner notification that can be used to display
 * information, warnings and errors to the user.
 *
 * :param String message: The notice message text.
 * :param severity:
 *    The severity of the notice (one of `notification.INFO`,
 *    `notification.SUCCESS`, or `notification.ERROR`)
 *
 * :returns:
 *   An object with a `close` method that can be used to close the banner.
 */
function banner(message, severity) {
    if (typeof severity === 'undefined' || severity === null) {
        severity = INFO;
    }

    var element = $(bannerTemplate)[0];
    var closed = false;

    var close = function () {
        if (closed) { return; }

        closed = true;

        $(element)
            .removeClass(bannerClasses.show)
            .removeClass(bannerClasses[severity]);

        // The removal of the above classes triggers a 400ms ease-out
        // transition, so we can dispose the element from the DOM after
        // 500ms.
        setTimeout(function () {
            $(element).remove();
        }, 500);
    };

    $(element)
        .addClass(bannerClasses.show)
        .addClass(bannerClasses[severity])
        .html(util.escapeHtml(message || ""))
        .appendTo(global.document.body);

    $(element).on('click', close);

    // Hide the notifier after 5s
    setTimeout(close, 5000);

    return {
        close: close
    };
}


exports.banner = banner;
exports.defaultNotifier = banner;

exports.INFO = INFO;
exports.SUCCESS = SUCCESS;
exports.ERROR = ERROR;
