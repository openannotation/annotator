/*package annotator.authz */

"use strict";

/**
 * data:: defaultAuthorizationPolicy
 *
 * Default authorization policy.
 */
exports.defaultAuthorizationPolicy = {
    /**
     * function:: defaultAuthorizationPolicy.permits(action,
     *                                               annotation,
     *                                               identity)
     *
     * Determines whether the user identified by `identity` is permitted to
     * perform the specified action on the given annotation.
     *
     * If the annotation has a "permissions" object property, then actions will
     * be permitted if either of the following are true:
     *
     *   a) annotation.permissions[action] is undefined or null,
     *   b) annotation.permissions[action] is an Array containing `identity`.
     *
     * If the annotation has a "user" property, then actions will be permitted
     * only if `identity` matches this "user" property.
     *
     * If the annotation has neither a "permissions" property nor a "user"
     * property, then all actions will be permitted.
     *
     * :param String action: The action the user wishes to perform.
     * :param annotation:
     * :param identity: The identity of the user.
     *
     * :returns Boolean: Whether the action is permitted.
     */
    permits: function permits(action, annotation, identity) {
        var userid = this.authorizedUserId(identity);

        if (annotation.permissions) {
            // Fine-grained authorization on permissions field
            var tokens = annotation.permissions[action];

            if (typeof tokens === 'undefined' || tokens === null) {
                // Missing tokens array for this action: anyone can perform
                // action.
                return true;
            }

            for (var i = 0, len = tokens.length; i < len; i++) {
                if (userid === tokens[i]) {
                    return true;
                }
            }

            // No tokens matched: action should not be performed.
            return false;
        } else if (annotation.user) {
            // Coarse-grained authorization
            return userid === annotation.user;
        }

        // No authorization info on annotation: free-for-all!
        return true;
    },

    /**
     * function:: defaultAuthorizationPolicy.authorizedUserId(identity)
     *
     * Returns the authorized userid for the user identified by `identity`.
     */
    authorizedUserId: function authorizedUserId(identity) {
        return identity;
    }
};
