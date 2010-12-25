$ = jQuery

fixtureElem = null
fixtureMemo = {}

this.setFixtureElem = (elem) ->
  fixtureElem = elem

this.fix = () ->
  fixtureElem

this.getFixture = (fname) ->
  if not fixtureMemo[fname]?
    fixtureMemo[fname] = $.ajax({
      url: "fixtures/#{fname}.html"
      async: false
    }).responseText

  fixtureMemo[fname]

this.addFixture = (fname) ->
  $(this.getFixture(fname)).appendTo(fixtureElem)

this.clearFixtures = () ->
  $(fixtureElem).empty()

this.mockAjax = (fname) ->
  $.getScript("ajax/#{fname}.js")

this.clearMockAjax = () ->
  $.mockjaxClear()

class this.MockSelection
  rangeCount: 1
  isCollapsed: false

  constructor: (fixElem, data) ->
    @commonAncestor = fixElem

    @commonAncestorXPath = $(fixElem).xpath()[0]

    @startContainer = this.resolvePath(data[0])
    @startOffset    = data[1]
    @endContainer   = this.resolvePath(data[2])
    @endOffset      = data[3]
    @expectation    = data[4]
    @description    = data[5]

  getRangeAt: () ->
    {
      startContainer: @startContainer
      startOffset:    @startOffset
      endContainer:   @endContainer
      endOffset:      @endOffset
      commonAncestorContainer: @commonAncestor
    }

  resolvePath: (path) ->
    if typeof path is "number"
      $(@commonAncestor).textNodes()[path]
    else if typeof path is "string"
      this.resolveXPath(@commonAncestorXPath + path)

  resolveXPath: (xpath) ->
    document.evaluate( xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue

this.textInNormedRange = (range) ->
  textNodes = $(range.commonAncestor).textNodes()
  textNodes = textNodes[textNodes.index(range.start)..textNodes.index(range.end)].get()
  _.reduce(textNodes, ((acc, next) -> acc += next.nodeValue), "")

