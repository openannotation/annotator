.. default-domain: js

annotator.identity package
==========================

..  function:: annotator.identity.simple()
    
    A module that configures and registers an instance of
    :class:`annotator.identity.SimpleIdentityPolicy`.


..  class:: annotator.identity.SimpleIdentityPolicy
    
    A simple identity policy that considers the identity to be an opaque
    identifier.


..  data:: annotator.identity.SimpleIdentityPolicy.identity
    
    Default identity. Defaults to `null`, which disables identity-related
    functionality.
    
    This is not part of the identity policy public interface, but provides a
    simple way for you to set a fixed current user::
    
        app.ident.identity = 'bob';


..  function:: annotator.identity.SimpleIdentityPolicy.prototype.who()
    
    Returns the current user identity.


