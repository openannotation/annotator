/*package annotator.storage */

"use strict";

var util = require('./util');
var $ = util.$;
var _t = util.gettext;
var Promise = util.Promise;


// id returns an identifier unique within this session
var id = (function () {
    var counter;
    counter = -1;
    return function () {
        return counter += 1;
    };
}());


/**
 * function:: debug()
 *
 * A storage component that can be used to print details of the annotation
 * persistence processes to the console when developing other parts of
 * Annotator.
 *
 * Use as an extension module::
 *
 *     app.include(annotator.storage.debug);
 *
 */
exports.debug = function () {
    function trace(action, annotation) {
        var copyAnno = JSON.parse(JSON.stringify(annotation));
        console.debug("annotator.storage.debug: " + action, copyAnno);
    }

    return {
        create: function (annotation) {
            annotation.id = id();
            trace('create', annotation);
            return annotation;
        },

        update: function (annotation) {
            trace('update', annotation);
            return annotation;
        },

        'delete': function (annotation) {
            trace('destroy', annotation);
            return annotation;
        },

        query: function (queryObj) {
            trace('query', queryObj);
            return {results: [], meta: {total: 0}};
        },

        configure: function (registry) {
            registry.registerUtility(this, 'storage');
        }
    };
};


/**
 * function:: noop()
 *
 * A no-op storage component. It swallows all calls and does the bare minimum
 * needed. Needless to say, it does not provide any real persistence.
 *
 * Use as a extension module::
 *
 *     app.include(annotator.storage.noop);
 *
 */
exports.noop = function () {
    return {
        create: function (annotation) {
            if (typeof annotation.id === 'undefined' ||
                annotation.id === null) {
                annotation.id = id();
            }
            return annotation;
        },

        update: function (annotation) {
            return annotation;
        },

        'delete': function (annotation) {
            return annotation;
        },

        query: function () {
            return {results: []};
        },

        configure: function (registry) {
            registry.registerUtility(this, 'storage');
        }
    };
};


var HttpStorage;


/**
 * function:: http([options])
 *
 * A module which configures an instance of
 * :class:`annotator.storage.HttpStorage` as the storage component.
 *
 * :param Object options:
 *   Configuration options. For available options see
 *   :attr:`~annotator.storage.HttpStorage.options`.
 */
exports.http = function http(options) {
    // This gets overridden on app start
    var notify = function () {};

    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    // Use the notifier unless an onError handler has been set.
    options.onError = options.onError || function (msg, xhr) {
        console.error(msg, xhr);
        notify(msg, 'error');
    };

    var storage = new HttpStorage(options);

    return {
        configure: function (registry) {
            registry.registerUtility(storage, 'storage');
        },

        start: function (app) {
            notify = app.notify;
        }
    };
};


/**
 * class:: HttpStorage([options])
 *
 * HttpStorage is a storage component that talks to a remote JSON + HTTP API
 * that should be relatively easy to implement with any web application
 * framework.
 *
 * :param Object options: See :attr:`~annotator.storage.HttpStorage.options`.
 */
HttpStorage = exports.HttpStorage = function HttpStorage(options) {
    this.options = $.extend(true, {}, HttpStorage.options, options);
    this.onError = this.options.onError;
};

/**
 * function:: HttpStorage.prototype.create(annotation)
 *
 * Create an annotation.
 *
 * **Examples**::
 *
 *     store.create({text: "my new annotation comment"})
 *     // => Results in an HTTP POST request to the server containing the
 *     //    annotation as serialised JSON.
 *
 * :param Object annotation: An annotation.
 * :returns: The request object.
 * :rtype: Promise
 */
HttpStorage.prototype.create = function (annotation) {
    return this._apiRequest('create', annotation);
};

/**
 * function:: HttpStorage.prototype.update(annotation)
 *
 * Update an annotation.
 *
 * **Examples**::
 *
 *     store.update({id: "blah", text: "updated annotation comment"})
 *     // => Results in an HTTP PUT request to the server containing the
 *     //    annotation as serialised JSON.
 *
 * :param Object annotation: An annotation. Must contain an `id`.
 * :returns: The request object.
 * :rtype: Promise
 */
HttpStorage.prototype.update = function (annotation) {
    return this._apiRequest('update', annotation);
};

/**
 * function:: HttpStorage.prototype.delete(annotation)
 *
 * Delete an annotation.
 *
 * **Examples**::
 *
 *     store.delete({id: "blah"})
 *     // => Results in an HTTP DELETE request to the server.
 *
 * :param Object annotation: An annotation. Must contain an `id`.
 * :returns: The request object.
 * :rtype: Promise
 */
HttpStorage.prototype['delete'] = function (annotation) {
    return this._apiRequest('destroy', annotation);
};

/**
 * function:: HttpStorage.prototype.query(queryObj)
 *
 * Searches for annotations matching the specified query.
 *
 * :param Object queryObj: An object describing the query.
 * :returns:
 *   A promise, resolves to an object containing query `results` and `meta`.
 * :rtype: Promise
 */
HttpStorage.prototype.query = function (queryObj) {
    return this._apiRequest('search', queryObj)
    .then(function (obj) {
        var rows = obj.rows;
        delete obj.rows;
        return {results: rows, meta: obj};
    });
};

/**
 * function:: HttpStorage.prototype.setHeader(name, value)
 *
 * Set a custom HTTP header to be sent with every request.
 *
 * **Examples**::
 *
 *     store.setHeader('X-My-Custom-Header', 'MyCustomValue')
 *
 * :param string name: The header name.
 * :param string value: The header value.
 */
HttpStorage.prototype.setHeader = function (key, value) {
    this.options.headers[key] = value;
};

/*
 * Helper method to build an XHR request for a specified action and
 * object.
 *
 * :param String action: The action: "search", "create", "update" or "destroy".
 * :param obj: The data to be sent, either annotation object or query string.
 *
 * :returns: The request object.
 * :rtype: jqXHR
 */
HttpStorage.prototype._apiRequest = function (action, obj) {
    var id = obj && obj.id;
    var url = this._urlFor(action, id);
    var options = this._apiRequestOptions(action, obj);

    var request = $.ajax(url, options);

    // Append the id and action to the request object
    // for use in the error callback.
    request._id = id;
    request._action = action;
    return request;
};

/*
 * Builds an options object suitable for use in a jQuery.ajax() call.
 *
 * :param String action: The action: "search", "create", "update" or "destroy".
 * :param obj: The data to be sent, either annotation object or query string.
 *
 * :returns: $.ajax() options.
 * :rtype: Object
 */
HttpStorage.prototype._apiRequestOptions = function (action, obj) {
    var method = this._methodFor(action);
    var self = this;

    var opts = {
        type: method,
        dataType: "json",
        error: function () { self._onError.apply(self, arguments); },
        headers: this.options.headers
    };

    // If emulateHTTP is enabled, we send a POST and put the real method in an
    // HTTP request header.
    if (this.options.emulateHTTP && (method === 'PUT' || method === 'DELETE')) {
        opts.headers = $.extend(opts.headers, {
            'X-HTTP-Method-Override': method
        });
        opts.type = 'POST';
    }

    // Don't JSONify obj if making search request.
    if (action === "search") {
        opts = $.extend(opts, {data: obj});
        return opts;
    }

    var data = obj && JSON.stringify(obj);

    // If emulateJSON is enabled, we send a form request (the correct
    // contentType will be set automatically by jQuery), and put the
    // JSON-encoded payload in the "json" key.
    if (this.options.emulateJSON) {
        opts.data = {json: data};
        if (this.options.emulateHTTP) {
            opts.data._method = method;
        }
        return opts;
    }

    opts = $.extend(opts, {
        data: data,
        contentType: "application/json; charset=utf-8"
    });
    return opts;
};

/*
 * Builds the appropriate URL from the options for the action provided.
 *
 * :param String action:
 * :param id: The annotation id as a String or Number.
 *
 * :returns String: URL for the request.
 */
HttpStorage.prototype._urlFor = function (action, id) {
    if (typeof id === 'undefined' || id === null) {
        id = '';
    }

    var url = '';
    if (typeof this.options.prefix !== 'undefined' &&
        this.options.prefix !== null) {
        url = this.options.prefix;
    }

    url += this.options.urls[action];
    // If there's an '{id}' in the URL, then fill in the ID.
    url = url.replace(/\{id\}/, id);
    return url;
};

/*
 * Maps an action to an HTTP method.
 *
 * :param String action:
 * :returns String: Method for the request.
 */
HttpStorage.prototype._methodFor = function (action) {
    var table = {
        create: 'POST',
        update: 'PUT',
        destroy: 'DELETE',
        search: 'GET'
    };

    return table[action];
};

/*
 * jQuery.ajax() callback. Displays an error notification to the user if
 * the request failed.
 *
 * :param jqXHR: The jqXMLHttpRequest object.
 */
HttpStorage.prototype._onError = function (xhr) {
    if (typeof this.onError !== 'function') {
        return;
    }

    var message;
    if (xhr.status === 400) {
        message = _t("The annotation store did not understand the request! " +
                     "(Error 400)");
    } else if (xhr.status === 401) {
        message = _t("You must be logged in to perform this operation! " +
                     "(Error 401)");
    } else if (xhr.status === 403) {
        message = _t("You don't have permission to perform this operation! " +
                     "(Error 403)");
    } else if (xhr.status === 404) {
        message = _t("Could not connect to the annotation store! " +
                     "(Error 404)");
    } else if (xhr.status === 500) {
        message = _t("Internal error in annotation store! " +
                     "(Error 500)");
    } else {
        message = _t("Unknown error while speaking to annotation store!");
    }
    this.onError(message, xhr);
};

/**
 * attribute:: HttpStorage.options
 *
 * Available configuration options for HttpStorage. See below.
 */
HttpStorage.options = {
    /**
     * attribute:: HttpStorage.options.emulateHTTP
     *
     * Should the storage emulate HTTP methods like PUT and DELETE for
     * interaction with legacy web servers? Setting this to `true` will fake
     * HTTP `PUT` and `DELETE` requests with an HTTP `POST`, and will set the
     * request header `X-HTTP-Method-Override` with the name of the desired
     * method.
     *
     * **Default**: ``false``
     */
    emulateHTTP: false,

    /**
     * attribute:: HttpStorage.options.emulateJSON
     *
     * Should the storage emulate JSON POST/PUT payloads by sending its requests
     * as application/x-www-form-urlencoded with a single key, "json"
     *
     * **Default**: ``false``
     */
    emulateJSON: false,

    /**
     * attribute:: HttpStorage.options.headers
     *
     * A set of custom headers that will be sent with every request. See also
     * the setHeader method.
     *
     * **Default**: ``{}``
     */
    headers: {},

    /**
     * attribute:: HttpStorage.options.onError
     *
     * Callback, called if a remote request throws an error.
     */
    onError: function (message) {
        console.error("API request failed: " + message);
    },

    /**
     * attribute:: HttpStorage.options.prefix
     *
     * This is the API endpoint. If the server supports Cross Origin Resource
     * Sharing (CORS) a full URL can be used here.
     *
     * **Default**: ``'/store'``
     */
    prefix: '/store',

    /**
     * attribute:: HttpStorage.options.urls
     *
     * The server URLs for each available action. These URLs can be anything but
     * must respond to the appropriate HTTP method. The URLs are Level 1 URI
     * Templates as defined in RFC6570:
     *
     *    http://tools.ietf.org/html/rfc6570#section-1.2
     *
     *  **Default**::
     *
     *      {
     *          create: '/annotations',
     *          update: '/annotations/{id}',
     *          destroy: '/annotations/{id}',
     *          search: '/search'
     *      }
     */
    urls: {
        create: '/annotations',
        update: '/annotations/{id}',
        destroy: '/annotations/{id}',
        search: '/search'
    }
};


/**
 * class:: StorageAdapter(store, runHook)
 *
 * StorageAdapter wraps a concrete implementation of the Storage interface, and
 * ensures that the appropriate hooks are fired when annotations are created,
 * updated, deleted, etc.
 *
 * :param store: The Store implementation which manages persistence
 * :param Function runHook: A function which can be used to run lifecycle hooks
 */
function StorageAdapter(store, runHook) {
    this.store = store;
    this.runHook = runHook;
}

/**
 * function:: StorageAdapter.prototype.create(obj)
 *
 * Creates and returns a new annotation object.
 *
 * Runs the 'beforeAnnotationCreated' hook to allow the new annotation to be
 * initialized or its creation prevented.
 *
 * Runs the 'annotationCreated' hook when the new annotation has been created
 * by the store.
 *
 * **Examples**:
 *
 * ::
 *
 *     registry.on('beforeAnnotationCreated', function (annotation) {
 *         annotation.myProperty = 'This is a custom property';
 *     });
 *     registry.create({}); // Resolves to {myProperty: "This is a…"}
 *
 *
 * :param Object annotation: An object from which to create an annotation.
 * :returns Promise: Resolves to annotation object when stored.
 */
StorageAdapter.prototype.create = function (obj) {
    if (typeof obj === 'undefined' || obj === null) {
        obj = {};
    }
    return this._cycle(
        obj,
        'create',
        'beforeAnnotationCreated',
        'annotationCreated'
    );
};

/**
 * function:: StorageAdapter.prototype.update(obj)
 *
 * Updates an annotation.
 *
 * Runs the 'beforeAnnotationUpdated' hook to allow an annotation to be
 * modified before being passed to the store, or for an update to be prevented.
 *
 * Runs the 'annotationUpdated' hook when the annotation has been updated by
 * the store.
 *
 * **Examples**:
 *
 * ::
 *
 *     annotation = {tags: 'apples oranges pears'};
 *     registry.on('beforeAnnotationUpdated', function (annotation) {
 *         // validate or modify a property.
 *         annotation.tags = annotation.tags.split(' ')
 *     });
 *     registry.update(annotation)
 *     // => Resolves to {tags: ["apples", "oranges", "pears"]}
 *
 * :param Object annotation: An annotation object to update.
 * :returns Promise: Resolves to annotation object when stored.
 */
StorageAdapter.prototype.update = function (obj) {
    if (typeof obj.id === 'undefined' || obj.id === null) {
        throw new TypeError("annotation must have an id for update()");
    }
    return this._cycle(
        obj,
        'update',
        'beforeAnnotationUpdated',
        'annotationUpdated'
    );
};

/**
 * function:: StorageAdapter.prototype.delete(obj)
 *
 * Deletes the annotation.
 *
 * Runs the 'beforeAnnotationDeleted' hook to allow an annotation to be
 * modified before being passed to the store, or for the a deletion to be
 * prevented.
 *
 * Runs the 'annotationDeleted' hook when the annotation has been deleted by
 * the store.
 *
 * :param Object annotation: An annotation object to delete.
 * :returns Promise: Resolves to annotation object when deleted.
 */
StorageAdapter.prototype['delete'] = function (obj) {
    if (typeof obj.id === 'undefined' || obj.id === null) {
        throw new TypeError("annotation must have an id for delete()");
    }
    return this._cycle(
        obj,
        'delete',
        'beforeAnnotationDeleted',
        'annotationDeleted'
    );
};

/**
 * function:: StorageAdapter.prototype.query(query)
 *
 * Queries the store
 *
 * :param Object query:
 *   A query. This may be interpreted differently by different stores.
 *
 * :returns Promise: Resolves to the store return value.
 */
StorageAdapter.prototype.query = function (query) {
    return Promise.resolve(this.store.query(query));
};

/**
 * function:: StorageAdapter.prototype.load(query)
 *
 * Load and draw annotations from a given query.
 *
 * Runs the 'load' hook to allow modules to respond to annotations being loaded.
 *
 * :param Object query:
 *   A query. This may be interpreted differently by different stores.
 *
 * :returns Promise: Resolves when loading is complete.
 */
StorageAdapter.prototype.load = function (query) {
    var self = this;
    return this.query(query)
        .then(function (data) {
            self.runHook('annotationsLoaded', [data.results]);
        });
};

// Cycle a store event, keeping track of the annotation object and updating it
// as necessary.
StorageAdapter.prototype._cycle = function (
    obj,
    storeFunc,
    beforeEvent,
    afterEvent
) {
    var self = this;
    return this.runHook(beforeEvent, [obj])
        .then(function () {
            var safeCopy = $.extend(true, {}, obj);
            delete safeCopy._local;

            // We use Promise.resolve() to coerce the result of the store
            // function, which can be either a value or a promise, to a promise.
            var result = self.store[storeFunc](safeCopy);
            return Promise.resolve(result);
        })
        .then(function (ret) {
            // Empty obj without changing identity
            for (var k in obj) {
                if (obj.hasOwnProperty(k)) {
                    if (k !== '_local') {
                        delete obj[k];
                    }
                }
            }

            // Update with store return value
            $.extend(obj, ret);
            self.runHook(afterEvent, [obj]);
            return obj;
        });
};

exports.StorageAdapter = StorageAdapter;
