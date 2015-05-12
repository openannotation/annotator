``annotator.ext.document``
==========================

This module collects metadata from the loaded page and adds it to new
annotations in the ``document`` field. Types of metadata collected at present
include:

- Page title::

    <title>Annotator - Annotating the Web</title>

- ``rel=alternate``, ``rel=shortlink``, ``rel=bookmark``, and ``rel=canonical``
  link tags::

    <link rel="alternate" href="foo.pdf" type="application/pdf"></link>
    <link rel="alternate" href="foo.doc" type="application/msword"></link>
    <link rel="bookmark" href="http://example.com/bookmark"></link>
    <link rel="alternate" href="es/foo.html" hreflang="es" type="text/html"></link>
    <link rel="alternate" href="feed" type="application/rss+xml"></link>
    <link rel="canonical" href="http://example.com/bookmark/canonical.html"></link>
    <link rel="shortlink" href="http://example.com/bookmark/short"></link>

- Highwire tags::

    <meta name="citation_doi" content="10.1175/JCLI-D-11-00015.1">
    <meta name="citation_title" content="Foo">
    <meta name="citation_pdf_url" content="foo.pdf">

- Dublin Core tags::

    <meta name="dc.identifier" content="doi:10.1175/JCLI-D-11-00015.1">
    <meta name="dc.identifier" content="isbn:123456789">
    <meta name="DC.type" content="Article">

- Facebook Open Graph tags::

    <meta property="og:url" content="http://example.com">

- Twitter card tags::

    <meta name="twitter:site" content="@okfn">

- Favicon::

    <link rel="icon" href="http://example.com/images/icon.ico"></link>

- Eprints tags::

    <meta name="eprints.title" content="Computer Lib / Dream Machines">

- PRISM tags::

    <meta name="prism.title" content="Literary Machines">
