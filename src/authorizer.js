/*package annotator.authorizer */

"use strict";

/**
 * class:: DefaultAuthorizer([options])
 *
 * Default authorizer
 *
 * :param Object options:
 *   Configuration options.
 *
 *   - `userId`: Custom function mapping an identity to a userId.
 */
function DefaultAuthorizer(options) {
    this.options = options || {};

    if (typeof this.options.userId === 'function') {
        this.userId = this.options.userId;
    }
}

/**
 * function:: DefaultAuthorizer.prototype.permits(action, annotation, identity)
 *
 * Determines whether the user identified by identity is permitted to perform
 * the specified action on the given annotation.
 *
 * If the annotation has a "permissions" object property, then actions will be
 * permitted if either of the following are true:
 *
 *   a) annotation.permissions[action] is undefined or null,
 *   b) annotation.permissions[action] is an Array containing the userId of the
 *      passed identity.
 *
 * If the annotation has a "user" property, then actions will be permitted only
 * if the userId of identity matches this "user" property.
 *
 * If the annotation has neither a "permissions" property nor a "user" property,
 * then all actions will be permitted.
 *
 * :param String action: The action the user wishes to perform
 * :param Object annotation:
 * :param identity: The identity of the user
 *
 * :returns Boolean: Whether the action is permitted
 */
DefaultAuthorizer.prototype.permits = function permits(
    action, annotation, identity
) {
    if (annotation.permissions) {
        // Fine-grained authorization on permissions field
        var tokens = annotation.permissions[action];

        if (typeof tokens === 'undefined' || tokens === null) {
            // Missing tokens array for this action: anyone can perform action.
            return true;
        }

        for (var i = 0, len = tokens.length; i < len; i++) {
            if (this.userId(identity) === tokens[i]) {
                return true;
            }
        }

        // No tokens matched: action should not be performed.
        return false;
    } else if (annotation.user) {
        // Coarse-grained authorization
        return this.userId(identity) === annotation.user;
    }

    // No authorization info on annotation: free-for-all!
    return true;
};

/**
 * function:: DefaultAuthorizer.prototype.userId(identity)
 *
 * A function for mapping an identity to a primitive userId. This default
 * implementation simply returns the identity, and can be used with identities
 * that are primitives (strings, integers).
 *
 * :param identity: A user identity.
 * :returns: The userId of the passed identity.
 */
DefaultAuthorizer.prototype.userId = function userId(identity) {
    return identity;
};


function Default(options) {
    return function () {
        return new DefaultAuthorizer(options);
    };
}


exports.Default = Default;
