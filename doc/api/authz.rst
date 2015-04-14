.. default-domain: js

annotator.authz package
=======================

..  data:: annotator.authz.defaultAuthorizationPolicy
    
    Default authorization policy.


..  function:: annotator.authz.defaultAuthorizationPolicy.permits(action,
                                                  annotation,
                                                  identity)
    
    Determines whether the user identified by `identity` is permitted to
    perform the specified action on the given annotation.
    
    If the annotation has a "permissions" object property, then actions will
    be permitted if either of the following are true:
    
      a) annotation.permissions[action] is undefined or null,
      b) annotation.permissions[action] is an Array containing `identity`.
    
    If the annotation has a "user" property, then actions will be permitted
    only if `identity` matches this "user" property.
    
    If the annotation has neither a "permissions" property nor a "user"
    property, then all actions will be permitted.
    
    :param String action: The action the user wishes to perform.
    :param annotation:
    :param identity: The identity of the user.
    
    :returns Boolean: Whether the action is permitted.


..  function:: annotator.authz.defaultAuthorizationPolicy.authorizedUserId(identity)
    
    Returns the authorized userid for the user identified by `identity`.


