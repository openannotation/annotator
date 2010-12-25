(function() {
  var $, fixtureElem, fixtureMemo;
  $ = jQuery;
  fixtureElem = null;
  fixtureMemo = {};
  this.setFixtureElem = function(elem) {
    return fixtureElem = elem;
  };
  this.fix = function() {
    return fixtureElem;
  };
  this.getFixture = function(fname) {
    if (!(fixtureMemo[fname] != null)) {
      fixtureMemo[fname] = $.ajax({
        url: "fixtures/" + fname + ".html",
        async: false
      }).responseText;
    }
    return fixtureMemo[fname];
  };
  this.addFixture = function(fname) {
    return $(this.getFixture(fname)).appendTo(fixtureElem);
  };
  this.clearFixtures = function() {
    return $(fixtureElem).empty();
  };
  this.mockAjax = function(fname) {
    return $.getScript("ajax/" + fname + ".js");
  };
  this.clearMockAjax = function() {
    return $.mockjaxClear();
  };
  this.MockSelection = (function() {
    MockSelection.prototype.rangeCount = 1;
    MockSelection.prototype.isCollapsed = false;
    function MockSelection(fixElem, data) {
      this.commonAncestor = fixElem;
      this.commonAncestorXPath = $(fixElem).xpath()[0];
      this.startContainer = this.resolvePath(data[0]);
      this.startOffset = data[1];
      this.endContainer = this.resolvePath(data[2]);
      this.endOffset = data[3];
      this.expectation = data[4];
      this.description = data[5];
    }
    MockSelection.prototype.getRangeAt = function() {
      return {
        startContainer: this.startContainer,
        startOffset: this.startOffset,
        endContainer: this.endContainer,
        endOffset: this.endOffset,
        commonAncestorContainer: this.commonAncestor
      };
    };
    MockSelection.prototype.resolvePath = function(path) {
      if (typeof path === "number") {
        return $(this.commonAncestor).textNodes()[path];
      } else if (typeof path === "string") {
        return this.resolveXPath(this.commonAncestorXPath + path);
      }
    };
    MockSelection.prototype.resolveXPath = function(xpath) {
      return document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    };
    return MockSelection;
  })();
  this.textInNormedRange = function(range) {
    var textNodes;
    textNodes = $(range.commonAncestor).textNodes();
    textNodes = textNodes.slice(textNodes.index(range.start), (textNodes.index(range.end) + 1) || 9e9).get();
    return _.reduce(textNodes, (function(acc, next) {
      return acc += next.nodeValue;
    }), "");
  };
}).call(this);
