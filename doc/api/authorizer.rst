.. default-domain: js

annotator.authorizer package
============================

..  class:: annotator.authorizer.DefaultAuthorizer([options])
    
    Default authorizer
    
    :param Object options:
      Configuration options.
    
      - `userId`: Custom function mapping an identity to a userId.


..  function:: annotator.authorizer.DefaultAuthorizer.prototype.permits(action, annotation, identity)
    
    Determines whether the user identified by identity is permitted to perform
    the specified action on the given annotation.
    
    If the annotation has a "permissions" object property, then actions will be
    permitted if either of the following are true:
    
      a) annotation.permissions[action] is undefined or null,
      b) annotation.permissions[action] is an Array containing the userId of the
         passed identity.
    
    If the annotation has a "user" property, then actions will be permitted only
    if the userId of identity matches this "user" property.
    
    If the annotation has neither a "permissions" property nor a "user" property,
    then all actions will be permitted.
    
    :param String action: The action the user wishes to perform
    :param Object annotation:
    :param identity: The identity of the user
    
    :returns Boolean: Whether the action is permitted


..  function:: annotator.authorizer.DefaultAuthorizer.prototype.userId(identity)
    
    A function for mapping an identity to a primitive userId. This default
    implementation simply returns the identity, and can be used with identities
    that are primitives (strings, integers).
    
    :param identity: A user identity.
    :returns: The userId of the passed identity.


