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
    head.append('<meta name="citation_doi" content="10.1175/JCLI-D-11-00015.1">')
    head.append('<meta name="citation_pdf_url" content="foo.pdf">')
    head.append('<meta name="dc.identifier" content="doi:10.1175/JCLI-D-11-00015.1">')

    annotation = null

    beforeEach ->
      annotation = annotator.createAnnotation()

    it 'can create annotation', ->
      assert.ok(annotation)

    it 'should have a document', ->
      assert.ok(annotation.document)

    it 'should have a title', ->
      assert.equal(annotation.document.title, 'Mocha')

    it 'should have links', ->
      assert.ok(annotation.document.link)
      assert.equal(annotation.document.link.length, 5)
      assert.equal(annotation.document.link[0].href, "foo.pdf")
      assert.equal(annotation.document.link[0].type, "application/pdf")
      assert.equal(annotation.document.link[1].href, "foo.doc")
      assert.equal(annotation.document.link[1].type, "application/msword")
      assert.equal(annotation.document.link[2].href, "doi:10.1175/JCLI-D-11-00015.1")
      assert.equal(annotation.document.link[3].href, "foo.pdf")
      assert.equal(annotation.document.link[3].type, "application/pdf")
      assert.equal(annotation.document.link[4].href, "doi:10.1175/JCLI-D-11-00015.1")
