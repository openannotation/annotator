.. default-domain: js

annotator.identity package
==========================

..  data:: annotator.identity.defaultIdentityPolicy
    
    Default identity policy.


..  data:: annotator.identity.defaultIdentityPolicy.identity
    
    Default identity. Defaults to `null`, which disables identity-related
    functionality.
    
    This is not part of the identity policy public interface, but provides a
    simple way for you to set a fixed current user::
    
        app.ident.identity = 'bob';


..  function:: annotator.identity.defaultIdentityPolicy.who()
    
    Returns the current user identity.


