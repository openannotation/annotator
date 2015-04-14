.. default-domain: js

annotator.registry package
==========================

..  class:: annotator.registry.Registry()
    
    Registry is an application registry. It serves a registry of configuration
    information consulted by an Annotator application while running. Configurable
    components are managed through the registry.


..  function:: annotator.registry.Registry.prototype.registerUtility(component, iface)
    
    Register component `component` as an implementer of interface `iface`.
    
    :param component: The component to register.
    :param string iface:


..  function:: annotator.registry.Registry.prototype.getUtility(iface)
    
    Get component implementing interface `iface`. Throws :class:`LookupError` if
    no matching component is found.
    
    :param string iface:
    :returns: Component matching `iface`, if found.
    :throws LookupError:


..  function:: annotator.registry.Registry.prototype.queryUtility(iface)
    
    Get component implementing interface `iface`. Returns `null` if no matching
    component is found.
    
    :param string iface:
    :returns: Component matching `iface`, if found; `null` otherwise.


..  class:: annotator.registry.LookupError(iface)
    
    The error thrown when a registry component lookup fails.


