describe 'Annotator.Plugin.Document', ->
  $fix = null
  annotator = null

  beforeEach ->
    annotator = new Annotator($('<div></div>')[0], {})
    annotator.addPlugin('Document')

  afterEach  -> $(document).unbind()

  describe 'has an annotator', ->
    it 'should have an annotator', ->
      assert.ok(annotator)

  describe 'has the plugin', ->
    it 'should have Document plugin', ->
      assert.ok('Document' of annotator.plugins)

  describe 'annotation should have some metadata', ->
    # add some metadata to the page
    head = $("head")
    head.append('<link rel="alternate" href="foo.pdf" type="application/pdf"></link>')
    head.append('<link rel="alternate" href="foo.doc" type="application/msword"></link>')
    head.append('<link rel="bookmark" href="http://example.com/bookmark"></link>')
    head.append('<meta name="citation_doi" content="10.1175/JCLI-D-11-00015.1">')
    head.append('<meta name="citation_title" content="Foo">')
    head.append('<meta name="citation_pdf_url" content="foo.pdf">')
    head.append('<meta name="dc.identifier" content="doi:10.1175/JCLI-D-11-00015.1">')
    head.append('<meta name="DC.type" content="Article">')
    head.append('<meta property="og:url" content="http://example.com">')
    head.append('<link rel="icon" href="http://example.com/images/icon.ico"></link>')

    annotation = null

    beforeEach ->
      annotation = annotator.createAnnotation()

    it 'can create annotation', ->
      assert.ok(annotation)

    it 'should have a document', ->
      assert.ok(annotation.document)

    it 'should have a title, derived from scholar metadata if possible', ->
      assert.equal(annotation.document.title, 'Foo')

    it 'should have links with absoulte hrefs and types', ->
      assert.ok(annotation.document.link)
      assert.equal(annotation.document.link.length, 7)
      assert.match(annotation.document.link[0].href, /^.+runner.html(\?.*)?$/)
      assert.equal(annotation.document.link[1].rel, "alternate")
      assert.match(annotation.document.link[1].href, /^.+foo\.pdf$/)
      assert.equal(annotation.document.link[1].type, "application/pdf")
      assert.equal(annotation.document.link[2].rel, "alternate")
      assert.match(annotation.document.link[2].href, /^.+foo\.doc$/)
      assert.equal(annotation.document.link[2].type, "application/msword")
      assert.equal(annotation.document.link[3].rel, "bookmark")
      assert.equal(annotation.document.link[3].href, "http://example.com/bookmark")
      assert.equal(annotation.document.link[4].href, "doi:10.1175/JCLI-D-11-00015.1")
      assert.match(annotation.document.link[5].href, /.+foo\.pdf$/)
      assert.equal(annotation.document.link[5].type, "application/pdf")
      assert.equal(annotation.document.link[6].href, "doi:10.1175/JCLI-D-11-00015.1")

    it 'should have google scholar metadata', ->
      assert.ok(annotation.document.scholar)
      assert.deepEqual(annotation.document.scholar.citation_pdf_url, ['foo.pdf'])
      assert.deepEqual(annotation.document.scholar.citation_doi, ['10.1175/JCLI-D-11-00015.1'])
      assert.deepEqual(annotation.document.scholar.citation_title, ['Foo'])

    it 'should have dublincore metadata', ->
      assert.ok(annotation.document.dc)
      assert.deepEqual(annotation.document.dc.identifier, ["doi:10.1175/JCLI-D-11-00015.1"])
      assert.deepEqual(annotation.document.dc.type, ["Article"])

    it 'should have opengraph metadata', ->
      assert.ok(annotation.document.og)
      assert.deepEqual(annotation.document.og.url, ["http://example.com"])
     
    it 'should have unique uris', ->
      uris = annotator.plugins.Document.uris()
      assert.equal(uris.length, 5)

    it 'should have a favicon', ->
      assert.equal(
        annotation.document.favicon
        'http://example.com/images/icon.ico'
      )

