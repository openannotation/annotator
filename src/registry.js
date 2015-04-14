/*package annotator.registry */

"use strict";

/**
 * class:: Registry()
 *
 * Registry is an application registry. It serves a registry of configuration
 * information consulted by an Annotator application while running. Configurable
 * components are managed through the registry.
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
 * :param string iface:
 */
Registry.prototype.registerUtility = function (component, iface) {
    this.utilities[iface] = component;
};

/**
 * function:: Registry.prototype.getUtility(iface)
 *
 * Get component implementing interface `iface`. Throws :class:`LookupError` if
 * no matching component is found.
 *
 * :param string iface:
 * :returns: Component matching `iface`, if found.
 * :throws LookupError:
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
 * :param string iface:
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
