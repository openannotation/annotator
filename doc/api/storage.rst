.. default-domain: js

annotator.storage package
=========================

..  function:: annotator.storage.debug()
    
    A storage component that can be used to print details of the annotation
    persistence processes to the console when developing other parts of
    Annotator.
    
    Use as an extension module::
    
        app.include(annotator.storage.debug);


..  function:: annotator.storage.noop()
    
    A no-op storage component. It swallows all calls and does the bare minimum
    needed. Needless to say, it does not provide any real persistence.
    
    Use as a extension module::
    
        app.include(annotator.storage.noop);


..  function:: annotator.storage.http([options])
    
    A module which configures an instance of
    :class:`annotator.storage.HttpStorage` as the storage component.
    
    :param Object options:
      Configuration options. For available options see
      :attr:`~annotator.storage.HttpStorage.options`.


..  class:: annotator.storage.HttpStorage([options])
    
    HttpStorage is a storage component that talks to a remote JSON + HTTP API
    that should be relatively easy to implement with any web application
    framework.
    
    :param Object options: See :attr:`~annotator.storage.HttpStorage.options`.


..  function:: annotator.storage.HttpStorage.prototype.create(annotation)
    
    Create an annotation.
    
    **Examples**::
    
        store.create({text: "my new annotation comment"})
        // => Results in an HTTP POST request to the server containing the
        //    annotation as serialised JSON.
    
    :param Object annotation: An annotation.
    :returns: The request object.
    :rtype: Promise


..  function:: annotator.storage.HttpStorage.prototype.update(annotation)
    
    Update an annotation.
    
    **Examples**::
    
        store.update({id: "blah", text: "updated annotation comment"})
        // => Results in an HTTP PUT request to the server containing the
        //    annotation as serialised JSON.
    
    :param Object annotation: An annotation. Must contain an `id`.
    :returns: The request object.
    :rtype: Promise


..  function:: annotator.storage.HttpStorage.prototype.delete(annotation)
    
    Delete an annotation.
    
    **Examples**::
    
        store.delete({id: "blah"})
        // => Results in an HTTP DELETE request to the server.
    
    :param Object annotation: An annotation. Must contain an `id`.
    :returns: The request object.
    :rtype: Promise


..  function:: annotator.storage.HttpStorage.prototype.query(queryObj)
    
    Searches for annotations matching the specified query.
    
    :param Object queryObj: An object describing the query.
    :returns:
      A promise, resolves to an object containing query `results` and `meta`.
    :rtype: Promise


..  function:: annotator.storage.HttpStorage.prototype.setHeader(name, value)
    
    Set a custom HTTP header to be sent with every request.
    
    **Examples**::
    
        store.setHeader('X-My-Custom-Header', 'MyCustomValue')
    
    :param string name: The header name.
    :param string value: The header value.


..  attribute:: annotator.storage.HttpStorage.options
    
    Available configuration options for HttpStorage. See below.


..  attribute:: annotator.storage.HttpStorage.options.emulateHTTP
    
    Should the storage emulate HTTP methods like PUT and DELETE for
    interaction with legacy web servers? Setting this to `true` will fake
    HTTP `PUT` and `DELETE` requests with an HTTP `POST`, and will set the
    request header `X-HTTP-Method-Override` with the name of the desired
    method.
    
    **Default**: ``false``


..  attribute:: annotator.storage.HttpStorage.options.emulateJSON
    
    Should the storage emulate JSON POST/PUT payloads by sending its requests
    as application/x-www-form-urlencoded with a single key, "json"
    
    **Default**: ``false``


..  attribute:: annotator.storage.HttpStorage.options.headers
    
    A set of custom headers that will be sent with every request. See also
    the setHeader method.
    
    **Default**: ``{}``


..  attribute:: annotator.storage.HttpStorage.options.onError
    
    Callback, called if a remote request throws an error.


..  attribute:: annotator.storage.HttpStorage.options.prefix
    
    This is the API endpoint. If the server supports Cross Origin Resource
    Sharing (CORS) a full URL can be used here.
    
    **Default**: ``'/store'``


..  attribute:: annotator.storage.HttpStorage.options.urls
    
    The server URLs for each available action. These URLs can be anything but
    must respond to the appropriate HTTP method. The URLs are Level 1 URI
    Templates as defined in RFC6570:
    
       http://tools.ietf.org/html/rfc6570#section-1.2
    
     **Default**::
    
         {
             create: '/annotations',
             update: '/annotations/{id}',
             destroy: '/annotations/{id}',
             search: '/search'
         }


..  class:: annotator.storage.StorageAdapter(store, runHook)
    
    StorageAdapter wraps a concrete implementation of the Storage interface, and
    ensures that the appropriate hooks are fired when annotations are created,
    updated, deleted, etc.
    
    :param store: The Store implementation which manages persistence
    :param Function runHook: A function which can be used to run lifecycle hooks


..  function:: annotator.storage.StorageAdapter.prototype.create(obj)
    
    Creates and returns a new annotation object.
    
    Runs the 'beforeAnnotationCreated' hook to allow the new annotation to be
    initialized or its creation prevented.
    
    Runs the 'annotationCreated' hook when the new annotation has been created
    by the store.
    
    **Examples**:
    
    ::
    
        registry.on('beforeAnnotationCreated', function (annotation) {
            annotation.myProperty = 'This is a custom property';
        });
        registry.create({}); // Resolves to {myProperty: "This is a…"}
    
    
    :param Object annotation: An object from which to create an annotation.
    :returns Promise: Resolves to annotation object when stored.


..  function:: annotator.storage.StorageAdapter.prototype.update(obj)
    
    Updates an annotation.
    
    Runs the 'beforeAnnotationUpdated' hook to allow an annotation to be
    modified before being passed to the store, or for an update to be prevented.
    
    Runs the 'annotationUpdated' hook when the annotation has been updated by
    the store.
    
    **Examples**:
    
    ::
    
        annotation = {tags: 'apples oranges pears'};
        registry.on('beforeAnnotationUpdated', function (annotation) {
            // validate or modify a property.
            annotation.tags = annotation.tags.split(' ')
        });
        registry.update(annotation)
        // => Resolves to {tags: ["apples", "oranges", "pears"]}
    
    :param Object annotation: An annotation object to update.
    :returns Promise: Resolves to annotation object when stored.


..  function:: annotator.storage.StorageAdapter.prototype.delete(obj)
    
    Deletes the annotation.
    
    Runs the 'beforeAnnotationDeleted' hook to allow an annotation to be
    modified before being passed to the store, or for the a deletion to be
    prevented.
    
    Runs the 'annotationDeleted' hook when the annotation has been deleted by
    the store.
    
    :param Object annotation: An annotation object to delete.
    :returns Promise: Resolves to annotation object when deleted.


..  function:: annotator.storage.StorageAdapter.prototype.query(query)
    
    Queries the store
    
    :param Object query:
      A query. This may be interpreted differently by different stores.
    
    :returns Promise: Resolves to the store return value.


..  function:: annotator.storage.StorageAdapter.prototype.load(query)
    
    Load and draw annotations from a given query.
    
    Runs the 'load' hook to allow modules to respond to annotations being loaded.
    
    :param Object query:
      A query. This may be interpreted differently by different stores.
    
    :returns Promise: Resolves when loading is complete.


