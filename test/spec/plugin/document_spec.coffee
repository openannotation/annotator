{$} = require('../../../src/util')
Document = require('../../../src/plugin/document')


describe 'Annotator.Plugin.Document', ->
  $fix = null
  plugin = null
  metadata = null

  beforeEach ->
    plugin = new Document($('<div/>')[0])
    plugin.pluginInit()

  describe '#beforeAnnotationCreated', ->

    it 'should add a document field to the annotation', ->
      annotation = {}
      plugin.beforeAnnotationCreated(annotation)
      assert.property(annotation, 'document')

  describe '#getDocumentMetadata()', ->
    # add some metadata to the page
    head = $("head")
    head.append('<link rel="alternate" href="foo.pdf" type="application/pdf"></link>')
    head.append('<link rel="alternate" href="foo.doc" type="application/msword"></link>')
    head.append('<link rel="bookmark" href="http://example.com/bookmark"></link>')
    head.append('<meta name="citation_doi" content="10.1175/JCLI-D-11-00015.1">')
    head.append('<meta name="citation_title" content="Foo">')
    head.append('<meta name="citation_pdf_url" content="foo.pdf">')
    head.append('<meta name="dc.identifier" content="doi:10.1175/JCLI-D-11-00015.1">')
    head.append('<meta name="dc.identifier" content="isbn:123456789">')
    head.append('<meta name="DC.type" content="Article">')
    head.append('<meta property="og:url" content="http://example.com">')
    head.append('<meta name="twitter:site" content="@okfn">')
    head.append('<link rel="icon" href="http://example.com/images/icon.ico"></link>')
    head.append('<meta name="eprints.title" content="Computer Lib / Dream Machines">')
    head.append('<meta name="prism.title" content="Literary Machines">')

    beforeEach ->
      metadata = plugin.getDocumentMetadata()

    it 'should have a title, derived from highwire metadata if possible', ->
      assert.equal(metadata.title, 'Foo')

    it 'should have links with absoulte hrefs and types', ->
      assert.ok(metadata.link)
      assert.equal(metadata.link.length, 7)
      assert.match(metadata.link[0].href, /^.+runner.html#?(\?.*)?$/)
      assert.equal(metadata.link[1].rel, "alternate")
      assert.match(metadata.link[1].href, /^.+foo\.pdf$/)
      assert.equal(metadata.link[1].type, "application/pdf")
      assert.equal(metadata.link[2].rel, "alternate")
      assert.match(metadata.link[2].href, /^.+foo\.doc$/)
      assert.equal(metadata.link[2].type, "application/msword")
      assert.equal(metadata.link[3].rel, "bookmark")
      assert.equal(metadata.link[3].href, "http://example.com/bookmark")
      assert.equal(metadata.link[4].href, "doi:10.1175/JCLI-D-11-00015.1")
      assert.match(metadata.link[5].href, /.+foo\.pdf$/)
      assert.equal(metadata.link[5].type, "application/pdf")
      assert.equal(metadata.link[6].href, "doi:10.1175/JCLI-D-11-00015.1")

    it 'should have highwire metadata', ->
      assert.ok(metadata.highwire)
      assert.deepEqual(metadata.highwire.pdf_url, ['foo.pdf'])
      assert.deepEqual(metadata.highwire.doi, ['10.1175/JCLI-D-11-00015.1'])
      assert.deepEqual(metadata.highwire.title, ['Foo'])

    it 'should have dublincore metadata', ->
      assert.ok(metadata.dc)
      assert.deepEqual(metadata.dc.identifier, ["doi:10.1175/JCLI-D-11-00015.1", "isbn:123456789"])
      assert.deepEqual(metadata.dc.type, ["Article"])

    it 'should have facebook metadata', ->
      assert.ok(metadata.facebook)
      assert.deepEqual(metadata.facebook.url, ["http://example.com"])

    it 'should have eprints metadata', ->
      assert.ok(metadata.eprints)
      assert.deepEqual(metadata.eprints.title, ['Computer Lib / Dream Machines'])

    it 'should have prism metadata', ->
      assert.ok(metadata.prism)
      assert.deepEqual(metadata.prism.title, ['Literary Machines'])

     it 'should have twitter card metadata', ->
      assert.ok(metadata.twitter)
      assert.deepEqual(metadata.twitter.site, ['@okfn'])

    it 'should have a favicon', ->
      assert.equal(
        metadata.favicon
        'http://example.com/images/icon.ico'
      )

  describe '#uris()', ->
    it 'should de-duplicate uris', ->
      uris = plugin.uris()
      assert.equal(uris.length, 5)

  describe '#_absoluteUrl', ->
    it 'should add the protocol when the url starts with two slashes', ->
      result = plugin._absoluteUrl('//example.com/')
      assert.equal(result, 'http://example.com/')

    it 'should add a trailing slash when given an empty path', ->
      result = plugin._absoluteUrl('http://example.com')
      assert.equal(result, 'http://example.com/')

    it 'should make a relative path into an absolute url', ->
      result = plugin._absoluteUrl('path')
      expected = (
        document.location.protocol + '//' +
        document.location.host +
        document.location.pathname.replace(/[^\/]+$/, '') +
        'path'
      )
      assert.equal(result, expected)

    it 'should make an absolute path into an absolute url', ->
      result = plugin._absoluteUrl('/path')
      expected = (
        document.location.protocol + '//' +
        document.location.host +
        '/path'
      )
      assert.equal(result, expected)
