Storage
=======

Some kind of storage is needed to save your annotations after you leave
a web page.

To do this you can use the :doc:`plugins/store` and a remote JSON API. This
page describes the API expected by the Store plugin, and implemented by
the `reference backend <https://github.com/okfn/annotator-store>`__. It
is this backend that runs the `AnnotateIt <http://annotateit.org>`__ web
service.

Core storage API
----------------

The storage API is defined in terms of a ``prefix`` and a number of
endpoints. It attempts to follow the principles of
`REST <http://en.wikipedia.org/wiki/Representational_state_transfer>`__,
and emits JSON documents to be parsed by the Annotator. Each of the
following endpoints for the storage API is expected to be found on the
web at ``prefix`` + ``path``. For example, if the prefix were
``http://example.com/api``, then the **index** endpoint would be found
at ``http://example.com/api/annotations``.

General rules are those common to most REST APIs. If a resource cannot
be found, return ``404 NOT FOUND``. If an action is not permitted for
the current user, return ``401 NOT AUTHORIZED``, otherwise return
``200 OK``. Send JSON text with the header
``Content-Type: application/json``.

Below you can find details of the six core endpoints, **root**,
**index**, **create**, **read**, **update**, **delete**, as well as an
optional **search** API.

.. raw:: html

   <h3 style='color: #c00'>

WARNING:

.. raw:: html

   </h3>

The spec below requires you return ``303 SEE OTHER`` from the **create**
and **update** endpoints. Ideally this *is* what you'd do, but
unfortunately most modern browsers (Firefox and Webkit) still make a
hash of CORS requests when they include redirects. A simple workaround
for the time being is to return ``200 OK`` and the JSON annotation that
*would* be returned by the **read** endpoint in the body of the
**create** and **update** responses. See bugs in
`Chromium <http://code.google.com/p/chromium/issues/detail?id=70257>`__
and `Webkit <https://bugs.webkit.org/show_bug.cgi?id=57600>`__.

root
~~~~

-  method: ``GET``
-  path: ``/``
-  returns: object containing store metadata, including API version

Example:

::

    $ curl http://example.com/api/
    {
      "name": "Annotator Store API",
      "version": "2.0.0"
    }

index
~~~~~

-  method: ``GET``
-  path: ``/annotations``
-  returns: a list of all annotation objects

Example (see :doc:`annotation-format` for details of the format of
individual annotations):

.. code:: json

    $ curl http://example.com/api/annotations
    [
      {
        "text": "Example annotation text",
        "ranges": [ ... ],
        ...
      },
      {
        "text": "Another annotation",
        "ranges": [ ... ],
        ...
      },
      ...
    ]

create
~~~~~~

-  method: ``POST``
-  path: ``/annotations``
-  receives: an annotation object, sent with
   ``Content-Type: application/json``
-  returns: ``303 SEE OTHER`` redirect to the appropriate **read**
   endpoint

Example:

::

    $ curl -i -X POST \
           -H 'Content-Type: application/json' \
           -d '{"text": "Annotation text"}' \
           http://example.com/api/annotations
    HTTP/1.0 303 SEE OTHER
    Location: http://example.com/api/annotations/d41d8cd98f00b204e9800998ecf8427e
    ...

read
~~~~

-  method: ``GET``
-  path: ``/annotations/<id>``
-  returns: an annotation object

Example:

::

    $ curl http://example.com/api/annotations/d41d8cd98f00b204e9800998ecf8427e
    {
      "id": "d41d8cd98f00b204e9800998ecf8427e",
      "text": "Annotation text",
      ...
    }

update
~~~~~~

-  method: ``PUT``
-  path: ``/annotations/<id>``
-  receives: a (partial) annotation object, sent with
   ``Content-Type: application/json``
-  returns: ``303 SEE OTHER`` redirect to the appropriate **read**
   endpoint

Example:

::

    $ curl -i -X PUT \
           -H 'Content-Type: application/json' \
           -d '{"text": "Updated annotation text"}' \
           http://example.com/api/annotations/d41d8cd98f00b204e9800998ecf8427e
    HTTP/1.0 303 SEE OTHER
    Location: http://example.com/api/annotations/d41d8cd98f00b204e9800998ecf8427e
    ...

delete
~~~~~~

-  method: ``DELETE``
-  path: ``/annotations/<id>``
-  returns: ``204 NO CONTENT``, and -- obviously -- no content

::

    $ curl -i -X DELETE http://example.com/api/annotations/d41d8cd98f00b204e9800998ecf8427e
    HTTP/1.0 204 NO CONTENT
    Content-Length: 0

Search API
----------

You may also choose to implement a search API, which can be used by the
Store plugin's ``loadFromSearch`` configuration option.

search
~~~~~~

-  method: ``GET``
-  path: ``/search?text=foobar``
-  returns: an object with ``total`` and ``rows`` fields. ``total`` is
   an integer denoting the *total* number of annotations matched by the
   search, while ``rows`` is a list containing what might be a subset of
   these annotations.
-  If implemented, this method should also support the ``limit`` and
   ``offset`` query parameters for paging through results.

::

    $ curl http://example.com/api/search?text=annotation
    {
      "total": 43127,
      "rows": [
        {
          "id": "d41d8cd98f00b204e9800998ecf8427e",
          "text": "Updated annotation text",
          ...
        },
        ...
      ]
    }

Storage Implementations
-----------------------

-  Reference backend, a Python Flask app:
   https://github.com/okfn/annotator-store (in particular, see
   `store.py <https://github.com/okfn/annotator-store/blob/master/annotator/store.py>`__,
   although be aware that this file also deals with authentication and
   authorization, making the code a good deal more complex than would be
   required to implement what is described above).
-  PHP (Silex) and MongoDB-based basic implementation:
   https://github.com/julien-c/annotator-php (in particular, see
   `index.php <https://github.com/julien-c/annotator-php/blob/master/index.php>`__).
