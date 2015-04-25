/*package annotator.registry */

"use strict";

/**
 * class:: Registry()
 *
 * `Registry` is an application registry. It serves as a place to register and
 * find shared components in a running :class:`annotator.App`.
 *
 * You won't usually create your own `Registry` -- one will be created for you
 * by the :class:`~annotator.App`. If you are writing an Annotator module, you
 * can use the registry to provide or override a component of the Annotator
 * application.
 *
 * For example, if you are writing a module that overrides the "storage"
 * component, you will use the registry in your module's `configure` function to
 * register your component::
 *
 *     function myStorage () {
 *         return {
 *             configure: function (registry) {
 *                 registry.registerUtility(this, 'storage');
 *             },
 *             ...
 *         };
 *     }
 */
function Registry() {
    this.utilities = {};
}

/**
 * function:: Registry.prototype.registerUtility(component, iface)
 *
 * Register component `component` as an implementer of interface `iface`.
 *
 * :param component: The component to register.
 * :param string iface: The name of the interface.
 */
Registry.prototype.registerUtility = function (component, iface) {
    this.utilities[iface] = component;
};

/**
 * function:: Registry.prototype.getUtility(iface)
 *
 * Get component implementing interface `iface`.
 *
 * :param string iface: The name of the interface.
 * :returns: Component matching `iface`.
 * :throws LookupError: If no component is found for interface `iface`.
 */
Registry.prototype.getUtility = function (iface) {
    var component = this.queryUtility(iface);
    if (component === null) {
        throw new LookupError(iface);
    }
    return component;
};

/**
 * function:: Registry.prototype.queryUtility(iface)
 *
 * Get component implementing interface `iface`. Returns `null` if no matching
 * component is found.
 *
 * :param string iface: The name of the interface.
 * :returns: Component matching `iface`, if found; `null` otherwise.
 */
Registry.prototype.queryUtility = function (iface) {
    var component = this.utilities[iface];
    if (typeof component === 'undefined' || component === null) {
        return null;
    }
    return component;
};


/**
 * class:: LookupError(iface)
 *
 * The error thrown when a registry component lookup fails.
 */
function LookupError(iface) {
    this.name = 'LookupError';
    this.message = 'No utility registered for interface "' + iface + '".';
}
LookupError.prototype = Object.create(Error.prototype);
LookupError.prototype.constructor = LookupError;

exports.LookupError = LookupError;
exports.Registry = Registry;
