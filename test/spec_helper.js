;(function ($) {

var fixtureElem
var fixtureMemo = {}

this.setFixtureElem = function (elem) {
  fixtureElem = elem
}

this.fix = function () {
  return fixtureElem
}

this.getFixture = function (fname) {
  if (typeof(fixtureMemo[fname]) === 'undefined') {
    fixtureMemo[fname] = $.ajax({
      url: 'fixtures/' + fname + '.html',
      async: false
    }).responseText
  }

  return fixtureMemo[fname]
}

this.addFixture = function (fname) {
  $(this.getFixture(fname)).appendTo(fixtureElem)
}

this.clearFixtures = function () {
  $(fixtureElem).empty()
}

this.mockAjax = function (fname) {
  $.getScript('ajax/' + fname + '.js')
}

this.clearMockAjax = function () {
  $.mockjaxClear()
}

this.MockSelection = Class.extend({
  rangeCount: 1,
  isCollapsed: false,

  init: function (fixElem, data) {
    this.commonAncestor = fixElem

    this.commonAncestorXPath = $(fixElem).xpath()[0]

    this.startContainer = this.resolvePath(data[0])
    this.startOffset    = data[1]
    this.endContainer   = this.resolvePath(data[2])
    this.endOffset      = data[3]
    this.expectation    = data[4]
    this.description    = data[5]
  },

  getRangeAt: function () {
    return {
      startContainer: this.startContainer,
      startOffset:    this.startOffset,
      endContainer:   this.endContainer,
      endOffset:      this.endOffset,
      commonAncestorContainer: this.commonAncestor
    }
  },

  resolvePath: function (path) {
    if (typeof(path) === "number") {
      return $(this.commonAncestor).textNodes()[path]
    } else if (typeof(path) === "string") {
      return this.resolveXPath(this.commonAncestorXPath + path)
    }
  },

  resolveXPath: function (xpath) {
    return document.evaluate( xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue
  }
})

this.textInNormedRange = function (range) {
  textNodes = $(range.commonAncestor).textNodes()
  textNodes = textNodes.slice(textNodes.index(range.start),
                              textNodes.index(range.end) + 1).get()
  return _(textNodes).reduce(function (acc, next) {
    return acc += next.nodeValue
  }, "")
}

})(jQuery)

