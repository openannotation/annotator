
describe('jQuery.fn.textnodes()', function () {
  var $fix

  beforeEach(function () {
    addFixture('textNodes')
    $fix = $(fix())
  })

  afterEach(function () {
    clearFixtures()
  })

  it("returns an element's textNode descendants", function () {
    var textNodes = $fix.textNodes()
    var allText = _(textNodes).inject(function (acc, node) {
      return acc + node.nodeValue
    }, "").replace(/\s+/g, ' ')

    expect(allText).toEqual(' lorem ipsum dolor sit dolor sit amet. humpty dumpty. etc. ')
  })
})

describe('jQuery.fn.xpath()', function () {
  var $fix

  beforeEach(function () {
    addFixture('xpath')
    $fix = $(fix())
  })

  afterEach(function () {
    clearFixtures()
  })

  it("generates an XPath string for an element's position in the document", function () {
    // FIXME: this is quite fragile. A change to dom.html may well break these tests and the
    //        resulting xpaths will need to be changed.
    var pathToFixHTML = '/html/body/div'
    expect($fix.find('p').xpath()).toEqual([pathToFixHTML + '/p', pathToFixHTML + '/p[2]'])
    expect($fix.find('span').xpath()).toEqual([pathToFixHTML + '/ol/li[2]/span'])
    expect($fix.find('strong').xpath()).toEqual([pathToFixHTML + '/p[2]/strong'])
  })

  it('takes an optional parameter determining the element from which XPaths should be calculated', function () {
    ol = $fix.find('ol').get(0)
    expect($fix.find('li').xpath(ol)).toEqual(['/li', '/li[2]', '/li[3]'])
    expect($fix.find('span').xpath(ol)).toEqual(['/li[2]/span'])
  })
})

