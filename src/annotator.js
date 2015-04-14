/*package annotator */

"use strict";

var authorizer = require('./authorizer');
var core = require('./core');
var identifier = require('./identifier');
var notifier = require('./notifier');
var storage = require('./storage');
var util = require('./util');

var defaultUI = require('./plugin/defaultui').DefaultUI;

// Gettext
var _t = util.gettext;

// If wicked-good-xpath is available, install it. This will not overwrite any
// native XPath functionality.
var wgxpath = util.getGlobal().wgxpath;
if (typeof wgxpath !== "undefined" &&
    wgxpath !== null &&
    typeof wgxpath.install === "function") {
    wgxpath.install();
}

// Global instance registry
var instances = [];

var Annotator = core.Annotator.extend({
    /**
     * class:: Annotator(element[, options])
     *
     * Annotator represents a reasonable default annotator configuration,
     * providing a default set of plugins and a user interface.
     *
     * NOTE: If the Annotator is not supported by the current browser it will
     * not perform any setup and simply return a basic object. This allows
     * plugins to still be loaded but will not function as expected. It is
     * reccomended to call Annotator.supported() before creating the instance or
     * using the Unsupported plugin which will notify users that the Annotator
     * will not work.
     *
     * **Examples**:
     *
     * ::
     *
     *     var app = new annotator.Annotator(document.body);
     *
     * :param Element element: DOM Element to attach to.
     * :param Object options: Configuration options.
     */
    constructor: function (element, options) {
        core.Annotator.call(this);

        instances.push(this);

        // Return early if the annotator is not supported.
        if (!supported()) {
            return this;
        }

        this.registry.registerUtility(authorizer.Default({}), 'authorizer');
        this.registry.registerUtility(identifier.Default(null), 'identifier');
        this.registry.registerUtility(notifier.Banner, 'notifier');
        this.setStorage(storage.NullStorage);
        this.addPlugin(defaultUI(element, options));

        // For now, we set these properties explicitly on the registry. This is
        // not how (or where) this should be done once we have a separate
        // configuration stage.
        this.registry.authorizer = this.registry.getUtility('authorizer')();
        this.registry.identifier = this.registry.getUtility('identifier')();
        this.registry.notifier = this.registry.getUtility('notifier')();
    },

    /**
     * function:: Annotator.prototype.destroy()
     *
     * Destroy the current Annotator instance, unbinding all events and
     * disposing of all relevant elements.
     */
    destroy: function () {
        core.Annotator.prototype.destroy.call(this);

        var idx = instances.indexOf(this);
        if (idx !== -1) {
            instances.splice(idx, 1);
        }
    }
});


/**
 * function:: supported([details=false, scope=window])
 *
 * Examines `scope` (by default the global window object) to determine if
 * Annotator can be used in this environment.
 *
 * :returns Boolean:
 *   Whether Annotator can be used in `scope`, if `details` is
 *   false.
 * :returns Object:
 *   If `details` is true. Properties:
 *
 *   - `supported`: Boolean, whether Annotator can be used in `scope`.
 *   - `details`: Array of String reasons why Annotator cannot be used.
 */
function supported(details, scope) {
    if (typeof scope === 'undefined' || scope === null) {
        scope = util.getGlobal();
    }

    var errors = [];

    if (typeof scope.getSelection !== 'function') {
        errors.push(_t("current scope lacks an implementation of the W3C " +
                       "Range API"));
    }
    // We require a working JSON implementation.
    if (typeof scope.JSON === 'undefined' ||
        typeof scope.JSON.parse !== 'function' ||
        typeof scope.JSON.stringify !== 'function') {
        errors.push(_t("current scope lacks a working JSON implementation"));
    }

    if (errors.length > 0) {
        if (details) {
            return {
                supported: false,
                errors: errors
            };
        }
        return false;
    }
    if (details) {
        return {
            supported: true,
            errors: []
        };
    }
    return true;
}


exports.Annotator = Annotator;
exports.supported = supported;
