# annotator.identity package

<div class="function">

annotator.identity.simple()

A module that configures and registers an instance of
`annotator.identity.SimpleIdentityPolicy`.

</div>

<div class="annotator.identity.SimpleIdentityPolicy">

A simple identity policy that considers the identity to be an opaque
identifier.

</div>

<div class="data">

annotator.identity.SimpleIdentityPolicy.identity

Default identity. Defaults to <span class="title-ref">null</span>, which
disables identity-related functionality.

This is not part of the identity policy public interface, but provides a
simple way for you to set a fixed current user:

    app.ident.identity = 'bob';

</div>

<div class="function">

annotator.identity.SimpleIdentityPolicy.prototype.who()

Returns the current user identity.

</div>
