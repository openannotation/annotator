.. default-domain: js

annotator.registry package
==========================

..  class:: annotator.registry.Registry()
    
    `Registry` is an application registry. It serves as a place to register and
    find shared components in a running :class:`annotator.App`.

    You won't usually create your own `Registry` -- one will be created for you
    by the :class:`~annotator.App`. If you are writing an Annotator module, there
    are, broadly, two main scenarios in which you will need to interact with the
    registry.

    1. If you are writing a module which overrides some default component, such
       as the "storage" component, you will use the registry in your module's
       `configure` function to register your component::

           function myStorage () {
               return {
                   configure: function (registry) {
                       registry.registerUtility(this, 'storage');
                   },
                   ...
               };
           }

    2. If your module needs to interact with some of the core components of the
       `App`, then you will find these exposed on the `Registry` instance. For
       example, if your module needs to send a notification when the application
       starts, you can use the "notifier" component which is exposed as the
       ``notify()`` function on the registry::

           function myModule () {
               return {
                   start: function (registry) {
                       registry.notify("Hello, world!");
                   },
                   ...
               };
           }


..  function:: annotator.registry.Registry.prototype.registerUtility(component, iface)
    
    Register component `component` as an implementer of interface `iface`.
    
    :param component: The component to register.
    :param string iface: The name of the interface.


..  function:: annotator.registry.Registry.prototype.getUtility(iface)
    
    Get component implementing interface `iface`.
    
    :param string iface: The name of the interface.
    :returns: Component matching `iface`.
    :throws LookupError: If no component is found for interface `iface`.


..  function:: annotator.registry.Registry.prototype.queryUtility(iface)
    
    Get component implementing interface `iface`. Returns `null` if no matching
    component is found.
    
    :param string iface: The name of the interface.
    :returns: Component matching `iface`, if found; `null` otherwise.


..  class:: annotator.registry.LookupError(iface)
    
    The error thrown when a registry component lookup fails.


