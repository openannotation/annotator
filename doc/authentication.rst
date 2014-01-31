Authentication
==============

What's the authentication system for?
-------------------------------------

The simplest way to explain the role of the authentication system is by
example. Consider the following:

1. Alice builds a website with documents which need annotating, DocLand.

2. Alice registers DocLand with AnnotateIt, and receives a "consumer
   key/secret" pair.

3. Alice's users (Bob is one of them) login to her DocLand, and receive
   an authentication token, which is a cryptographic combination of
   (among other things) their unique user ID at DocLand, and DocLand's
   "consumer secret".

4. Bob's browser sends requests to AnnotateIt to save annotations, and
   these include the authentication token as part of the payload.

5. AnnotateIt can verify the Bob is a real user from DocLand, and thus
   stores his annotation.

So why go to all this trouble? Well, the point is really to save **you**
trouble. By implementing this authentication system (which shares key
ideas with the industry standard OAuth) you can provide your users with
the ability to annotate documents on your website without needing to
worry about implementing your own Annotator backend. You can use
`AnnotateIt <http://annotateit.org>`__ to provide the backend: all you
have to do is implement a token generator on your website (described
below).

This is the simple explanation, but if you're in need of more technical
details, keep reading.

Technical overview
------------------

How do we authorise users' browsers to create annotations on a
Consumer's behalf? There are three (and a half) entities involved:

1. The Service Provider (SP; AnnotateIt in the above example)
2. The Consumer (C; DocLand)
3. The User (U; Bob), and the User Agent (UA; Bob's browser)

Annotations are stored by the SP, which provides an API that the
Annotator's "Store" plugin understands.

Text to be annotated, and configuration of the clientside Annotator, is
provided by the Consumer.

Users will typically register with the Consumer -- we make no
assumptions about your user registration/authentication process other
than that it exists -- and the UA will, when visiting appropriate
sections of C's site, request an ``authToken`` from C. Typically, an
``authToken`` will only be provided if U is currently logged into C's
site.

Technical specification
-----------------------

It's unlikely you'll need to understand all of the following to get up
and running using AnnotateIt -- you can probably just copy and paste the
Python example given below -- but it's worth reading what follows if
you're doing anything unusual (such as giving out tokens to
unauthenticated users).

The Annotator ``authToken`` is a type of `JSON Web
Token <http://openid.net/specs/draft-jones-json-web-token-07.html>`__.
This document won't describe the details of the JWT specification, other
than to say that the token payload is signed by the consumer secret with
the HMAC-SHA256 algorithm, allowing the backend to verify that the
contents of the token haven't been interfered with while travelling from
the consumer. Numerous language implementations exist already
(`PyJWT <http://pypi.python.org/pypi/PyJWT>`__,
`jwt <https://rubygems.org/gems/jwt>`__ for Ruby,
`php-jwt <https://github.com/progrium/php-jwt>`__,
`JWT-CodeIgniter <https://github.com/b3457m0d3/JWT-CodeIgniter>`__...).

The required contents of the token payload are:

+-------------------+----------------------------------------------------------------------------------+------------------------------------------+
| key               | description                                                                      | example                                  |
+===================+==================================================================================+==========================================+
| ``consumerKey``   | the consumer key issued by the backend store                                     | ``"602368a0e905492fae87697edad14c3a"``   |
+-------------------+----------------------------------------------------------------------------------+------------------------------------------+
| ``userId``        | the consumer's **unique** identifier for the user to whom the token was issued   | ``"alice"``                              |
+-------------------+----------------------------------------------------------------------------------+------------------------------------------+
| ``issuedAt``      | the ISO8601 time at which the token was issued                                   | ``"2012-03-23T10:51:18Z"``               |
+-------------------+----------------------------------------------------------------------------------+------------------------------------------+
| ``ttl``           | the number of seconds after ``issuedAt`` for which the token is valid            | ``86400``                                |
+-------------------+----------------------------------------------------------------------------------+------------------------------------------+

You may wish the payload to contain other information (e.g. ``userRole``
or ``userGroups``) and arbitrary additional keys may be added to the
token. This will only be useful if the Annotator client and the SP pay
attention to these keys.

Lastly, note that the Annotator frontend does **not** verify the
authenticity of the tokens it receives. Only the SP is required to
verify authenticity of auth tokens before authorizing a request from the
Annotator frontend.

For reference, here's a Python implementation of a token generator,
suitable for dropping straight into your
`Flask <http://flask.pocoo.org>`__ or
`Django <https://www.djangoproject.com/>`__ project:

.. code:: python

    import datetime
    import jwt

    # Replace these with your details
    CONSUMER_KEY = 'yourconsumerkey'
    CONSUMER_SECRET = 'yourconsumersecret'

    # Only change this if you're sure you know what you're doing
    CONSUMER_TTL = 86400

    def generate_token(user_id):
        return jwt.encode({
          'consumerKey': CONSUMER_KEY,
          'userId': user_id,
          'issuedAt': _now().isoformat() + 'Z',
          'ttl': CONSUMER_TTL
        }, CONSUMER_SECRET)

    def _now():
        return datetime.datetime.utcnow().replace(microsecond=0)

Now all you need to do is expose an endpoint in your web application
that returns the token to logged-in users (say,
http://example.com/api/token), and you can set up the Annotator like so:

.. code:: javascript

    $(body).annotator()
           .annotator('setupPlugins', {tokenUrl: 'http://example.com/api/token'});

Colophon
--------

Original planning documents at:

-  http://lists.okfn.org/pipermail/okfn-help/2010-December/000977.html

Rehashed in Feb 2012:

-  http://lists.okfn.org/pipermail/annotator-dev/2012-January/000188.html
