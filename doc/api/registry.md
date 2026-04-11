# annotator.registry package

<div class="annotator.registry.Registry()">

<span class="title-ref">Registry</span> is an application registry. It
serves as a place to register and find shared components in a running
`annotator.App`.

You won't usually create your own
<span class="title-ref">Registry</span> -- one will be created for you
by the `~annotator.App`. If you are writing an Annotator module, you can
use the registry to provide or override a component of the Annotator
application.

For example, if you are writing a module that overrides the "storage"
component, you will use the registry in your module's
<span class="title-ref">configure</span> function to register your
component:

    function myStorage () {
        return {
            configure: function (registry) {
                registry.registerUtility(this, 'storage');
            },
            ...
        };
    }

</div>

<div class="function">

annotator.registry.Registry.prototype.registerUtility(component, iface)

Register component <span class="title-ref">component</span> as an
implementer of interface <span class="title-ref">iface</span>.

param component  
The component to register.

param string iface  
The name of the interface.

</div>

<div class="function">

annotator.registry.Registry.prototype.getUtility(iface)

Get component implementing interface
<span class="title-ref">iface</span>.

param string iface  
The name of the interface.

returns  
Component matching <span class="title-ref">iface</span>.

throws LookupError  
If no component is found for interface
<span class="title-ref">iface</span>.

</div>

<div class="function">

annotator.registry.Registry.prototype.queryUtility(iface)

Get component implementing interface
<span class="title-ref">iface</span>. Returns
<span class="title-ref">null</span> if no matching component is found.

param string iface  
The name of the interface.

returns  
Component matching <span class="title-ref">iface</span>, if found;
<span class="title-ref">null</span> otherwise.

</div>

<div class="annotator.registry.LookupError(iface)">

The error thrown when a registry component lookup fails.

</div>
