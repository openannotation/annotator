``Auth`` plugin
===============

The Auth plugin complements the :doc:`store` by providing
authentication for requests. This may be necessary if you are running
the Store on a separate domain or using a third party service like
annotateit.org.

The plugin works by requesting an authentication token from the local
server and then provides this in all requests to the store. For more
details see the :doc:`specification <../authentication>`.

Usage
-----

Adding the Auth plugin to the annotator is very simple. Simply add the
annotator to the page using the ``.annotator()`` jQuery plugin. Then
call the ``.addPlugin()`` method eg.
``.annotator('addPlugin', 'Auth')``.

.. code:: javascript

      var content = $('#content'));
      content.annotator('addPlugin', 'Auth', {
        tokenUrl: '/auth/token'
      });

Options
-------

The following options are available to the Auth plugin.

-  ``tokenUrl``: The URL to request the token from. Defaults to
   ``/auth/token``.
-  ``token``: An auth token. If this is present it will not be requested
   from the server. Defaults to ``null``.
-  ``autoFetch``: Whether to fetch the token when the plugin is loaded.
   Defaults to ``true``

Token format
^^^^^^^^^^^^

For details of the token format, see the page on :doc:`Annotator's
Authentication system <../authentication>`.
