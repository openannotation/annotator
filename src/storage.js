"use strict";

var Util = require('./util'),
    $ = Util.$,
    _t = Util.gettext,
    Promise = Util.Promise;


// id returns an identifier unique within this session
var id = (function () {
    var counter;
    counter = -1;
    return function () {
        return counter += 1;
    };
}());


// DebugStorage is a storage component that can be used to print details of the
// annotation persistence processes to the console when developing other parts
// of Annotator.
function DebugStorage () {
    function trace(action, annotation) {
        var copyAnno = JSON.parse(JSON.stringify(annotation));
        console.debug("DebugStore: " + action, copyAnno);
    }

    return {
        'create': function (annotation) {
            annotation.id = id();
            trace('create', annotation);
            return annotation;
        },

        'update': function (annotation) {
            trace('update', annotation);
            return annotation;
        },

        'delete': function (annotation) {
            trace('destroy', annotation);
            return annotation;
        },

        'query': function (queryObj) {
            trace('query', queryObj);
            return {results: [], metadata: {total: 0}};
        }
    };
}


// NullStorage is a no-op storage component. It swallows all calls and does the
// bare minimum needed. Needless to say, it does not provide any real
// persistence.
function NullStorage() {
    return {
        'create': function (annotation) {
            if (typeof annotation.id === 'undefined' ||
                annotation.id === null) {
                annotation.id = id();
            }
            return annotation;
        },

        'update': function (annotation) {
            return annotation;
        },

        'delete': function (annotation) {
            return annotation;
        },

        'query': function () {
            return {results: []};
        }
    };
}


// HTTPStorageImpl is a storage component that talks to a simple remote API that
// can be implemented with any web framework.
//
// options - An Object containing configuration options (optional).
//
// Returns a new instance.
function HTTPStorageImpl(options) {
    this.options = $.extend(true, {}, HTTPStorageImpl.options, options);
    this.onError = this.options.onError;
}

// Public: Create an annotation.
//
// annotation - An annotation Object to create.
//
// Examples
//
//   store.create({text: "my new annotation comment"})
//   # => Results in an HTTP POST request to the server containing the
//   #    annotation as serialised JSON.
//
// Returns a jqXHR object.
HTTPStorageImpl.prototype.create = function (annotation) {
    return this._apiRequest('create', annotation);
};

// Public: Update an annotation.
//
// annotation - An annotation Object to update.
//
// Examples
//
//   store.update({id: "blah", text: "updated annotation comment"})
//   # => Results in an HTTP PUT request to the server containing the
//   #    annotation as serialised JSON.
//
// Returns a jqXHR object.
HTTPStorageImpl.prototype.update = function (annotation) {
    return this._apiRequest('update', annotation);
};

// Public: Delete an annotation.
//
// annotation - An annotation Object that was deleted.
//
// Examples
//
//   store.delete({text: "my new annotation comment"})
//   # => Results in an HTTP DELETE request to the server.
//
// Returns a jqXHR object.
HTTPStorageImpl.prototype['delete'] = function (annotation) {
    return this._apiRequest('destroy', annotation);
};

// Public: Searches for annotations matching the specified query.
//
// Returns a Promise resolving to the query results and query metadata.
HTTPStorageImpl.prototype.query = function (queryObj) {
    var dfd = $.Deferred();
    this._apiRequest('search', queryObj)
        .done(function (obj) {
            var rows = obj.rows;
            delete obj.row;
            dfd.resolve({results: rows, metadata: obj});
        })
        .fail(function () {
            dfd.reject.apply(dfd, arguments);
        });
    return dfd.promise();
};

// Public: Set a custom HTTP header to be sent with every request.
//
// key   - The header name.
// value - The header value.
//
// Examples:
//
//   store.setHeader('X-My-Custom-Header', 'MyCustomValue')
//
// Returns nothing.
HTTPStorageImpl.prototype.setHeader = function (key, value) {
    this.options.headers[key] = value;
};

// Private: Helper method to build an XHR request for a specified action and
// object.
//
// action - The action String: "search", "create", "update" or "destroy".
// obj - The data to be sent, either annotation object or query string.
//
// Returns XMLHttpRequest object.
HTTPStorageImpl.prototype._apiRequest = function (action, obj) {
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

// Private: Builds an options object suitable for use in a jQuery.ajax() call.
//
// action - The action String: "search", "create", "update" or "destroy".
// obj - The data to be sent, either annotation object or query string.
//
// Returns Object literal of $.ajax() options.
HTTPStorageImpl.prototype._apiRequestOptions = function (action, obj) {
    var method = this._methodFor(action);

    var opts = {
        type: method,
        dataType: "json",
        error: this._onError,
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

// Private: Builds the appropriate URL from the options for the action provided.
//
// action - The action String.
// id     - The annotation id as a String or Number.
//
// Examples
//
//   store._urlFor('update', 34)
//   # => Returns "/store/annotations/34"
//
//   store._urlFor('search')
//   # => Returns "/store/search"
//
// Returns URL String.
HTTPStorageImpl.prototype._urlFor = function (action, id) {
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

// Private: Maps an action to an HTTP method.
//
// action - The action String.
//
// Examples
//
//   store._methodFor('update')  # => "PUT"
//   store._methodFor('destroy') # => "DELETE"
//
// Returns HTTP method String.
HTTPStorageImpl.prototype._methodFor = function (action) {
    var table = {
        create: 'POST',
        update: 'PUT',
        destroy: 'DELETE',
        search: 'GET'
    };

    return table[action];
};

// jQuery.ajax() callback. Displays an error notification to the user if
// the request failed.
//
// xhr - The jqXMLHttpRequest object.
//
// Returns nothing.
HTTPStorageImpl.prototype._onError = function (xhr) {
    var action = xhr._action;
    var message = _t("Sorry we could not ") + action + _t(" this annotation");

    if (xhr._action === 'search') {
        message = _t("Sorry we could not search the store for annotations");
    }

    if (xhr.status === 401) {
        message = _t("Sorry you are not allowed to ") +
                  action +
                  _t(" this annotation");
    } else if (xhr.status === 404) {
        message = _t("Sorry we could not connect to the annotations store");
    } else if (xhr.status === 500) {
        message = _t("Sorry something went wrong with the annotation store");
    }

    if (typeof this.onError === 'function') {
        this.onError(message, xhr);
    }
};

// HTTPStorageImpl configuration options
HTTPStorageImpl.options = {
    // Should the plugin emulate HTTP methods like PUT and DELETE for
    // interaction with legacy web servers? Setting this to `true` will fake
    // HTTP `PUT` and `DELETE` requests with an HTTP `POST`, and will set the
    // request header `X-HTTP-Method-Override` with the name of the desired
    // method.
    emulateHTTP: false,

    // Should the plugin emulate JSON POST/PUT payloads by sending its requests
    // as application/x-www-form-urlencoded with a single key, "json"
    emulateJSON: false,

    // A set of custom headers that will be sent with every request. See also
    // the setHeader method.
    headers: {},

    // Callback, called if a remote request throws an error.
    onError: function (message) {
        console.error("API request failed: " + message);
    },

    // This is the API endpoint. If the server supports Cross Origin Resource
    // Sharing (CORS) a full URL can be used here.
    prefix: '/store',

    // The server URLs for each available action. These URLs can be anything but
    // must respond to the appropriate HTTP method. The URLs are Level 1 URI
    // Templates as defined in RFC6570:
    //
    //    http://tools.ietf.org/html/rfc6570#section-1.2
    //
    // create:  POST
    // update:  PUT
    // destroy: DELETE
    // search:  GET
    urls: {
        create: '/annotations',
        update: '/annotations/{id}',
        destroy: '/annotations/{id}',
        search: '/search'
    }
};


// FIXME: Remove the need for this wrapper function.
function HTTPStorage(options) {
    return new HTTPStorageImpl(options);
}


// StorageAdapter wraps a concrete implementation of the Storage interface, and
// ensures that the appropriate hooks are fired when annotations are created,
// updated, deleted, etc.
//
// store - The Store implementation which manages persistence
// runHook - A function which can be used to run lifecycle hooks
function StorageAdapter(store, runHook) {
    this.store = store;
    this.runHook = runHook;
}

// Creates and returns a new annotation object.
//
// Runs the 'beforeAnnotationCreated' hook to allow the new annotation to be
// initialized or its creation prevented.
//
// Runs the 'annotationCreated' hook when the new annotation has been created
// by the store.
//
// annotation - An Object from which to create an annotation.
//
// Examples
//
//   registry.on 'beforeAnnotationCreated', (annotation) ->
//     annotation.myProperty = 'This is a custom property'
//   registry.create({}) # Resolves to {myProperty: "This is a…"}
//
// Returns a Promise of an annotation Object.
StorageAdapter.prototype.create = function (obj) {
    if (typeof obj === 'undefined' || obj === null) {
        obj = {};
    }
    return this._cycle(
        obj,
        'create',
        'onBeforeAnnotationCreated',
        'onAnnotationCreated'
    );
};

// Updates an annotation.
//
// Runs the 'beforeAnnotationUpdated' hook to allow an annotation to be
// modified before being passed to the store, or for an update to be prevented.
//
// Runs the 'annotationUpdated' hook when the annotation has been updated by
// the store.
//
// annotation - An annotation Object to updated.
//
// Examples
//
//   annotation = {tags: 'apples oranges pears'}
//   registry.on 'beforeAnnotationUpdated', (annotation) ->
//     # validate or modify a property.
//     annotation.tags = annotation.tags.split(' ')
//   registry.update(annotation)
//   # => Returns ["apples", "oranges", "pears"]
//
// Returns a Promise of an annotation Object.
StorageAdapter.prototype.update = function (obj) {
    if (typeof obj.id === 'undefined' || obj.id === null) {
        throw new TypeError("annotation must have an id for update()");
    }
    return this._cycle(
        obj,
        'update',
        'onBeforeAnnotationUpdated',
        'onAnnotationUpdated'
    );
};

// Public: Deletes the annotation.
//
// Runs the 'beforeAnnotationDeleted' hook to allow an annotation to be
// modified before being passed to the store, or for the a deletion to be
// prevented.
//
// Runs the 'annotationDeleted' hook when the annotation has been deleted by
// the store.
//
// annotation - An annotation Object to delete.
//
// Returns a Promise of an annotation Object.
StorageAdapter.prototype['delete'] = function (obj) {
    if (typeof obj.id === 'undefined' || obj.id === null) {
        throw new TypeError("annotation must have an id for delete()");
    }
    return this._cycle(
        obj,
        'delete',
        'onBeforeAnnotationDeleted',
        'onAnnotationDeleted'
    );
};

// Public: Queries the store
//
// query - An Object defining a query. This may be interpreted differently by
//         different stores.
//
// Returns a Promise resolving to the store return value.
StorageAdapter.prototype.query = function (query) {
    return Promise.resolve(this.store.query(query));
};

// Public: Load and draw annotations from a given query.
//
// Runs the 'load' hook to allow plugins to respond to annotations being
// loaded.
//
// query - the query to pass to the backend
//
// Returns a Promise that resolves when loading is complete.
StorageAdapter.prototype.load = function (query) {
    var self = this;
    return this.query(query)
        .then(function (result) {
            self.runHook('onAnnotationsLoaded', [result]);
        });
};

// Private: cycle a store event, keeping track of the annotation object and
// updating it as necessary.
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


exports.DebugStorage = DebugStorage;
exports.HTTPStorage = HTTPStorage;
exports.NullStorage = NullStorage;
exports.StorageAdapter = StorageAdapter;
