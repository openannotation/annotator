/*package annotator.identity */

"use strict";


/**
 * data:: defaultIdentityPolicy
 *
 * Default identity policy.
 */
exports.defaultIdentityPolicy = {
    /**
     * data:: defaultIdentityPolicy.identity
     *
     * Default identity. Defaults to `null`, which disables identity-related
     * functionality.
     *
     * This is not part of the identity policy public interface, but provides a
     * simple way for you to set a fixed current user::
     *
     *     app.ident.identity = 'bob';
     */
    identity: null,

    /**
     * function:: defaultIdentityPolicy.who()
     *
     * Returns the current user identity.
     */
    who: function () { return this.identity; }
};
