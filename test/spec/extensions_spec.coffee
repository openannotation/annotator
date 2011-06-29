describe 'jQuery.fn.flatten()', ->
  it "flattens the contents of an Array", ->
    flattened = $.flatten([[1,2], 'lorem ipsum', [{}]])
    expect(flattened).toEqual([1, 2, 'lorem ipsum', {}])

describe 'jQuery.fn.textNodes()', ->
  $fix = null

  beforeEach ->
    addFixture 'textNodes'
    $fix = $(fix())

  afterEach -> clearFixtures()

  it "returns an element's textNode descendants", ->
    nodes = $fix.textNodes()
    text = (node.nodeValue for node in nodes)

    expectation = [ '\n  '
                  , 'lorem ipsum'
                  , '\n  '
                  , 'dolor sit'
                  , '\n'
                  , '\n'
                  , 'dolor sit '
                  , 'amet'
                  , '. humpty dumpty. etc.'
                  ]

    expect(text).toEqual(expectation)

describe 'jQuery.fn.xpath()', ->
  $fix = null

  beforeEach ->
    addFixture 'xpath'
    $fix = $(fix())

  afterEach -> clearFixtures()

  it "generates an XPath string for an element's position in the document", ->
    # FIXME: this is quite fragile. A change to dom.html may well break these tests and the
    #        resulting xpaths will need to be changed.
    if /Node\.js/.test(navigator.userAgent)
      pathToFixHTML = '/html/body'
    else
      pathToFixHTML = '/html/body/div'

    expect($fix.find('p').xpath()).toEqual([pathToFixHTML + '/p', pathToFixHTML + '/p[2]'])
    expect($fix.find('span').xpath()).toEqual([pathToFixHTML + '/ol/li[2]/span'])
    expect($fix.find('strong').xpath()).toEqual([pathToFixHTML + '/p[2]/strong'])

  it "takes an optional parameter determining the element from which XPaths should be calculated", ->
    ol = $fix.find('ol').get(0)
    expect($fix.find('li').xpath(ol)).toEqual(['/li', '/li[2]', '/li[3]'])
    expect($fix.find('span').xpath(ol)).toEqual(['/li[2]/span'])

describe 'jQuery.escape()', ->
  it "should escape any HTML special characters into entities", ->
    expect($.escape('<>"&')).toEqual('&lt;&gt;&quot;&amp;')

describe 'jQuery.fn.escape()', ->
  it "should set the innerHTML of the elements but escape any HTML into entities", ->
    div = $('<div />').escape('<>"&')
    # Match either &quot; or " as  JSDOM keeps quotes escaped but the browser does not. 
    expect(div.html()).toMatch(/&lt;&gt;(&quot;|")&amp;/)

    div = $('<div />').escape('<script>alert("hello")</script>')
    expect(div.html()).toMatch(/&lt;script&gt;alert\((&quot;|")hello(&quot;|")\)&lt;\/script&gt;/)

  it "should return the original jQuery collection", ->
    div = $('<div />').escape('<>"&')
    expect(div).toEqual(div)

  it "should return the equivalent of .html() if no arguments are passed", ->
    div = $('<div><strong>My div</strong></div>').escape('<>"&')
    expect(div.escape()).toEqual(div.html())
