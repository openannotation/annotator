/*package annotator.identifier */

"use strict";

/**
 * function:: Default(identity)
 *
 * Default identifier implementation.
 *
 * :param identity: The identity to report as the current user.
 * :returns: A function returning an identifier object.
 */
function Default(identity) {
    return function () {
        return {
            who: function () { return identity; }
        };
    };
}


exports.Default = Default;
