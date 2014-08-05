``Store`` plugin
================

This plugin sends annotations (serialised as JSON) to the server at key
events broadcast by the annotator.

Actions
-------

The following actions are performed by the annotator.

-  ``create``: POSTs an annotation (serialised as JSON) to the server.
   Called when the annotator publishes the "annotationCreated" event.
   The annotation is updated with any data (such as a newly created id)
   returned from the server.
-  ``update``: PUTs an annotation (serialised as JSON) on the server
   under its id. Called when the annotator publishes the
   "annotationUpdated" event. The annotation is updated with any data
   (such as a newly created id) returned from the server.
-  ``destroy``: Issues a DELETE request to server for the annotation.
-  ``search``: GETs all annotations relevant to the query. Should return
   a JSON object with a ``rows`` property containing an array of
   annotations.

Stores
------

For an example store check out our
`annotator-store <http://github.com/okfn/annotator-store>`__ project on
GitHub which you can use or examine as the basis for your own store. If
you're looking to get up and running quickly then
`annotateit.org <http://annotateit.org>`__ will store your annotations
remotely under your account.

Interface Overview
------------------

This plugin adds no additional UI to the Annotator but will display
error notifications if a request to the store fails.

Usage
-----

Adding the store plugin to the annotator is very simple. Simply add the
annotator to the page using the ``.annotator()`` jQuery plugin and
retrieve the annotator object using ``.data('annotator')``. Then add the
``Store`` plugin.

.. code:: javascript

    var content = $('#content').annotator();
        content.annotator('addPlugin', 'Store', {
          // The endpoint of the store on your server.
          prefix: '/store/endpoint',

          // Attach the uri of the current page to all annotations to allow search.
          annotationData: {
            'uri': 'http://this/document/only'
          },

          // This will perform a "search" action when the plugin loads. Will
          // request the last 20 annotations for the current url.
          // eg. /store/endpoint/search?limit=20&uri=http://this/document/only
          loadFromSearch: {
            'limit': 20,
            'uri': 'http://this/document/only'
          }
        });

Options
~~~~~~~

The following options are made available for customisation of the store.

-  ``prefix``: The store endpoint.
-  ``annotationData``: An object literal containing any data to attach
   to the annotation on submission.
-  ``loadFromSearch``: Search options for using the "search" action.
-  ``urls``: Custom URL paths.
-  ``showViewPermissionsCheckbox``: If ``true`` will display the "anyone
   can view this annotation" checkbox.
-  ``showEditPermissionsCheckbox``: If ``true`` will display the "anyone
   can edit this annotation" checkbox.

prefix
^^^^^^

This is the API endpoint. If the server supports Cross Origin Resource
Sharing (CORS) a full URL can be used here. Defaults to ``/store``.

NOTE: The trailing slash should be omitted.

Example:

.. code:: javascript

      $('#content').annotator('addPlugin', 'Store', {
        prefix: '/store/endpoint'
      });

annotationData
^^^^^^^^^^^^^^

Custom meta data that will be attached to every annotation that is sent
to the server. This *will* override previous values.

Example:

.. code:: javascript

      $('#content').annotator('addPlugin', 'Store', {
        // Attach a uri property to every annotation sent to the server.
        annotationData: {
          'uri': 'http://this/document/only'
        }
      });

loadFromSearch
^^^^^^^^^^^^^^

An object literal containing query string parameters to query the store.
If ``loadFromSearch`` is set, then we load the first batch of
annotations from the 'search' URL as set in ``options.urls`` instead of
the registry path 'prefix/read'. Defaults to ``false``.

Example:

.. code:: javascript

      $('#content').annotator('addPlugin', 'Store', {
        loadFromSearch: {
          'limit': 0,
          'all_fields': 1,
          'uri': 'http://this/document/only'
        }
      });

urls
^^^^

The server URLs for each available action (excluding ``prefix``). These
URLs can point anywhere but must respond to the appropriate HTTP method.
The ``:id`` token can be used anywhere in the URL and will be replaced
with the annotation id.

Methods for actions are as follows:

::

    create:  POST
    update:  PUT
    destroy: DELETE
    search:  GET

Example:

.. code:: javascript

      $('#content').annotator('addPlugin', 'Store', {
        urls: {
          // These are the default URLs.
          create:  '/annotations',
          update:  '/annotations/:id',
          destroy: '/annotations/:id',
          search:  '/search'
        }
      }):
