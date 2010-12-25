(function() {
  var $;
  $ = jQuery;
  describe('jQuery.fn.textnodes()', function() {
    var $fix;
    $fix = null;
    beforeEach(function() {
      addFixture('textNodes');
      return $fix = $(fix());
    });
    afterEach(function() {
      return clearFixtures();
    });
    return it("returns an element's textNode descendants", function() {
      var allText, textNodes;
      textNodes = $fix.textNodes();
      allText = _.inject(textNodes, function(acc, node) {
        return acc + node.nodeValue;
      }, "").replace(/\s+/g, ' ');
      return expect(allText).toEqual(' lorem ipsum dolor sit dolor sit amet. humpty dumpty. etc.');
    });
  });
  describe('jQuery.fn.xpath()', function() {
    var $fix;
    $fix = null;
    beforeEach(function() {
      addFixture('xpath');
      return $fix = $(fix());
    });
    afterEach(function() {
      return clearFixtures();
    });
    it("generates an XPath string for an element's position in the document", function() {
      var pathToFixHTML;
      pathToFixHTML = '/html/body/div';
      expect($fix.find('p').xpath()).toEqual([pathToFixHTML + '/p', pathToFixHTML + '/p[2]']);
      expect($fix.find('span').xpath()).toEqual([pathToFixHTML + '/ol/li[2]/span']);
      return expect($fix.find('strong').xpath()).toEqual([pathToFixHTML + '/p[2]/strong']);
    });
    return it("takes an optional parameter determining the element from which XPaths should be calculated", function() {
      var ol;
      ol = $fix.find('ol').get(0);
      expect($fix.find('li').xpath(ol)).toEqual(['/li', '/li[2]', '/li[3]']);
      return expect($fix.find('span').xpath(ol)).toEqual(['/li[2]/span']);
    });
  });
}).call(this);
