describe 'jQuery.fn.flatten()', ->
  it "flattens the contents of an Array", ->
    flattened = $.flatten([[1,2], 'lorem ipsum', [{}]])
    expect(flattened).toEqual([1, 2, 'lorem ipsum', {}])

describe 'jQuery.fn.textNodes()', ->
  $fix = null

  beforeEach ->
    addFixture 'textnodes'
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

  it "returns an empty jQuery collection when called in undefined node", ->
    result = $(undefined).textNodes()
    expect(result instanceof jQuery).toBe(true)
    expect(result.length).toBe(0)

  it "returns an element's TextNodes after Text.splitText() text has been called", ->
    # Build a very csutom fixture to replicate an issue in IE9 where calling
    # split text on an text node does not update the parents .childNodes value
    # which continues to return the unsplit text node.
    fixture = document.getElementById('fixtures') || $('body')[0];
    fixture.innerHTML = '';

    para = document.createElement('p');
    text = document.createTextNode('this is a paragraph of text');
    para.appendChild(text);
    fixture.appendChild(para);

    expect(para.childNodes.length).toBe(1);
    first = text.splitText(14);

    # Some basic assertions on the split text.
    expect(first.nodeValue).toBe('graph of text');
    expect(text.nodeValue).toBe('this is a para');
    expect(para.firstChild.nodeValue).toBe('this is a para');
    expect(para.lastChild.nodeValue).toBe('graph of text');

    # JSDom will only correctly return .text() contents after checking the
    # length of the para.childNodes object. IE9 will only returnt the contents
    # of the first node.
    # expect($(para).text()).toBe('this is a paragraph of text');

    # Both of the following tests fail in IE9 so we cannot rely on the
    # Text.childNodes property or jQuery.fn.contents() to retrieve the text
    # nodes.
    # expect(para.childNodes.length).toBe(2);
    # expect($(para).contents().length).toBe(2);

    expect($(para).textNodes().length).toBe(2);

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
