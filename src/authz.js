/*package annotator.authz */

"use strict";

var AclAuthzPolicy;


/**
 * function:: acl()
 *
 * A module that configures and registers an instance of
 * :class:`annotator.authz.AclAuthzPolicy`.
 *
 */
exports.acl = function acl() {
    var authorization = new AclAuthzPolicy();

    return {
        configure: function (registry) {
            registry.registerUtility(authorization, 'authorizationPolicy');
        }
    };
};


/**
 * class:: AclAuthzPolicy()
 *
 * An authorization policy that permits actions based on access control lists.
 *
 */
AclAuthzPolicy = exports.AclAuthzPolicy = function AclAuthzPolicy() {
};


/**
 * function:: AclAuthzPolicy.prototype.permits(action, context, identity)
 *
 * Determines whether the user identified by `identity` is permitted to
 * perform the specified action in the given context.
 *
 * If the context has a "permissions" object property, then actions will
 * be permitted if either of the following are true:
 *
 *   a) permissions[action] is undefined or null,
 *   b) permissions[action] is an Array containing the authorized userid
 *      for the given identity.
 *
 * If the context has no permissions associated with it then all actions
 * will be permitted.
 *
 * If the annotation has a "user" property, then actions will be permitted
 * only if `identity` matches this "user" property.
 *
 * If the annotation has neither a "permissions" property nor a "user"
 * property, then all actions will be permitted.
 *
 * :param String action: The action to perform.
 * :param context: The permissions context for the authorization check.
 * :param identity: The identity whose authorization is being checked.
 *
 * :returns Boolean: Whether the action is permitted in this context for this
 * identity.
 */
AclAuthzPolicy.prototype.permits = function (action, context, identity) {
    var userid = this.authorizedUserId(identity);
    var permissions = context.permissions;

    if (permissions) {
        // Fine-grained authorization on permissions field
        var tokens = permissions[action];

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
    } else if (context.user) {
        // Coarse-grained authorization
        return userid === context.user;
    }

    // No authorization info on context: free-for-all!
    return true;
};


/**
 * function:: AclAuthzPolicy.prototype.authorizedUserId(identity)
 *
 * Returns the authorized userid for the user identified by `identity`.
 */
AclAuthzPolicy.prototype.authorizedUserId = function (identity) {
    return identity;
};
