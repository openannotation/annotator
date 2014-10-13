"use strict";

/**
 * Default identifier
 *
 * @param {*} identity The identity to report as the current user
 */
function Default(identity) {
    return function () {
        return {
            who: function () { return identity; }
        };
    };
}


exports.Default = Default;
