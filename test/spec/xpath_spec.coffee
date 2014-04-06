h = require('helpers')
$ = require('../../src/util').$
xpath = require('../../src/xpath')

describe 'xpath', ->
  $fix = null

  beforeEach ->
    h.addFixture 'xpath'
    $fix = $(h.fix())

  afterEach ->
    h.clearFixtures()

  describe '#fromNode', ->

    it "generates an XPath string for an element's position in the document", ->
      # FIXME: this is quite fragile. A change to dom.html may well break these tests and the
      #        resulting xpaths will need to be changed.

      pathToFixHTML = '/html[1]/body[1]/div[1]'

      assert.deepEqual(xpath.fromNode($fix.find('p')), [pathToFixHTML + '/p[1]', pathToFixHTML + '/p[2]'])
      assert.deepEqual(xpath.fromNode($fix.find('span')), [pathToFixHTML + '/ol[1]/li[2]/span[1]'])
      assert.deepEqual(xpath.fromNode($fix.find('strong')), [pathToFixHTML + '/p[2]/strong[1]'])

    it "takes an optional parameter determining the element from which XPaths should be calculated", ->
      ol = $fix.find('ol').get(0)
      assert.deepEqual(xpath.fromNode($fix.find('li'), ol), ['/li[1]', '/li[2]', '/li[3]'])
      assert.deepEqual(xpath.fromNode($fix.find('span'), ol), ['/li[2]/span[1]'])

  describe "#toNode()", ->
    path = "/p[2]/strong"
    it "should parse a standard xpath string", ->
      node = xpath.toNode path, $fix[0]
      assert.equal(node, $('strong')[0])

    it "should parse an standard xpath string for an xml document", ->
      $.isXMLDoc = -> true
      node = xpath.toNode path, $fix[0]
      assert.equal(node, $('strong')[0])
