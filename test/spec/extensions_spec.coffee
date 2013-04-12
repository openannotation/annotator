describe 'jQuery.fn.flatten()', ->
  it "flattens the contents of an Array", ->
    flattened = $.flatten([[1,2], 'lorem ipsum', [{}]])
    assert.deepEqual(flattened, [1, 2, 'lorem ipsum', {}])

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

    assert.deepEqual(text, expectation)

  it "returns an empty jQuery collection when called in undefined node", ->
    result = $(undefined).textNodes()
    assert.instanceOf(result, jQuery)
    assert.lengthOf(result, 0)

  it "returns an element's TextNodes after Text.splitText() text has been called", ->
    # Build a very csutom fixture to replicate an issue in IE9 where calling
    # split text on an text node does not update the parents .childNodes value
    # which continues to return the unsplit text node.
    fixture = document.getElementById('fixtures') || $('body')[0]
    fixture.innerHTML = ''

    para = document.createElement('p')
    text = document.createTextNode('this is a paragraph of text')
    para.appendChild(text)
    fixture.appendChild(para)

    assert.lengthOf(para.childNodes, 1)
    first = text.splitText(14)

    # Some basic assertions on the split text.
    assert.equal(first.nodeValue, 'graph of text')
    assert.equal(text.nodeValue, 'this is a para')
    assert.equal(para.firstChild.nodeValue, 'this is a para')
    assert.equal(para.lastChild.nodeValue, 'graph of text')

    # JSDom will only correctly return .text() contents after checking the
    # length of the para.childNodes object. IE9 will only returnt the contents
    # of the first node.
    # assert.equal($(para).text(), 'this is a paragraph of text')

    # Both of the following tests fail in IE9 so we cannot rely on the
    # Text.childNodes property or jQuery.fn.contents() to retrieve the text
    # nodes.
    # assert.lengthOf(para.childNodes, 2)
    # assert.lengthOf($(para).contents(), 2)

    assert.lengthOf($(para).textNodes(), 2)

describe 'jQuery.fn.xpath()', ->
  $fix = null

  beforeEach ->
    addFixture 'xpath'
    $fix = $(fix())

  afterEach -> clearFixtures()

  it "generates an XPath string for an element's position in the document", ->
    # FIXME: this is quite fragile. A change to dom.html may well break these tests and the
    #        resulting xpaths will need to be changed.

    pathToFixHTML = '/html[1]/body[1]/div[1]'

    assert.deepEqual($fix.find('p').xpath(), [pathToFixHTML + '/p[1]', pathToFixHTML + '/p[2]'])
    assert.deepEqual($fix.find('span').xpath(), [pathToFixHTML + '/ol[1]/li[2]/span[1]'])
    assert.deepEqual($fix.find('strong').xpath(), [pathToFixHTML + '/p[2]/strong[1]'])

  it "takes an optional parameter determining the element from which XPaths should be calculated", ->
    ol = $fix.find('ol').get(0)
    assert.deepEqual($fix.find('li').xpath(ol), ['/li[1]', '/li[2]', '/li[3]'])
    assert.deepEqual($fix.find('span').xpath(ol), ['/li[2]/span[1]'])

describe 'jQuery.escape()', ->
  it "should escape any HTML special characters into entities", ->
    assert.equal($.escape('<>"&'), '&lt;&gt;&quot;&amp;')

describe 'jQuery.fn.escape()', ->
  it "should set the innerHTML of the elements but escape any HTML into entities", ->
    div = $('<div />').escape('<>"&')
    # Match either &quot; or " as  JSDOM keeps quotes escaped but the browser does not.
    assert.match(div.html(), /&lt;&gt;(&quot;|")&amp;/)

    div = $('<div />').escape('<script>alert("hello")</script>')
    assert.match(div.html(), /&lt;script&gt;alert\((&quot;|")hello(&quot;|")\)&lt;\/script&gt;/)

  it "should return the original jQuery collection", ->
    div = $('<div />')
    ret = div.escape('<>"&')
    assert.strictEqual(ret, div)

  it "should return the equivalent of .html() if no arguments are passed", ->
    div = $('<div><strong>My div</strong></div>').escape('<>"&')
    assert.equal(div.escape(), div.html())

describe 'jQuery.fn.reverse()', ->
  it "should, uh, reverse stuff", ->
    assert.deepEqual($([1,2,3]).reverse().get(), [3,2,1])
