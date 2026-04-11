# annotator.authz package

<div class="function">

annotator.authz.acl()

A module that configures and registers an instance of
`annotator.identity.AclAuthzPolicy`.

</div>

<div class="annotator.authz.AclAuthzPolicy()">

An authorization policy that permits actions based on access control
lists.

</div>

<div class="function">

annotator.authz.AclAuthzPolicy.prototype.permits(action, context,
identity)

Determines whether the user identified by
<span class="title-ref">identity</span> is permitted to perform the
specified action in the given context.

If the context has a "permissions" object property, then actions will be
permitted if either of the following are true:

> 1)  permissions\[action\] is undefined or null,
> 2)  permissions\[action\] is an Array containing the authorized userid
>     for the given identity.

If the context has no permissions associated with it then all actions
will be permitted.

If the annotation has a "user" property, then actions will be permitted
only if <span class="title-ref">identity</span> matches this "user"
property.

If the annotation has neither a "permissions" property nor a "user"
property, then all actions will be permitted.

param String action  
The action to perform.

param context  
The permissions context for the authorization check.

param identity  
The identity whose authorization is being checked.

returns Boolean  
Whether the action is permitted in this context for this identity.

</div>

<div class="function">

annotator.authz.AclAuthzPolicy.prototype.authorizedUserId( identity)

Returns the authorized userid for the user identified by
<span class="title-ref">identity</span>.

</div>
