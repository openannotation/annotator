$ = jQuery

describe 'jQuery.fn.textnodes()', ->
  $fix = null

  beforeEach ->
    addFixture 'textNodes'
    $fix = $(fix())

  afterEach -> clearFixtures()

  it "returns an element's textNode descendants", ->
    textNodes = $fix.textNodes()
    allText = _.inject(textNodes, (acc, node) ->
      acc + node.nodeValue
    , "").replace(/\s+/g, ' ')

    expect(allText).toEqual(' lorem ipsum dolor sit dolor sit amet. humpty dumpty. etc.')

describe 'jQuery.fn.xpath()', ->
  $fix = null

  beforeEach ->
    addFixture 'xpath'
    $fix = $(fix())

  afterEach -> clearFixtures()

  it "generates an XPath string for an element's position in the document", ->
    # FIXME: this is quite fragile. A change to dom.html may well break these tests and the
    #        resulting xpaths will need to be changed.
    pathToFixHTML = '/html/body/div'
    expect($fix.find('p').xpath()).toEqual([pathToFixHTML + '/p', pathToFixHTML + '/p[2]'])
    expect($fix.find('span').xpath()).toEqual([pathToFixHTML + '/ol/li[2]/span'])
    expect($fix.find('strong').xpath()).toEqual([pathToFixHTML + '/p[2]/strong'])

  it "takes an optional parameter determining the element from which XPaths should be calculated", ->
    ol = $fix.find('ol').get(0)
    expect($fix.find('li').xpath(ol)).toEqual(['/li', '/li[2]', '/li[3]'])
    expect($fix.find('span').xpath(ol)).toEqual(['/li[2]/span'])
