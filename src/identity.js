/*package annotator.identity */

"use strict";


var SimpleIdentityPolicy;


/**
 * function:: simple()
 *
 * A module that configures and registers an instance of
 * :class:`annotator.identity.SimpleIdentityPolicy`.
 */
exports.simple = function simple() {
    var identity = new SimpleIdentityPolicy();

    return {
        configure: function (registry) {
            registry.registerUtility(identity, 'identityPolicy');
        }
    };
};


/**
 * class:: SimpleIdentityPolicy
 *
 * A simple identity policy that considers the identity to be an opaque
 * identifier.
 */
SimpleIdentityPolicy = function SimpleIdentityPolicy() {
    /**
     * data:: SimpleIdentityPolicy.identity
     *
     * Default identity. Defaults to `null`, which disables identity-related
     * functionality.
     *
     * This is not part of the identity policy public interface, but provides a
     * simple way for you to set a fixed current user::
     *
     *     app.ident.identity = 'bob';
     */
    this.identity = null;
};
exports.SimpleIdentityPolicy = SimpleIdentityPolicy;


/**
 * function:: SimpleIdentityPolicy.prototype.who()
 *
 * Returns the current user identity.
 */
SimpleIdentityPolicy.prototype.who = function () {
    return this.identity;
};
