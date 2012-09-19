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

  getRangeAt: ->
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
    document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue

this.textInNormedRange = (range) ->
  textNodes = $(range.commonAncestor).textNodes()
  textNodes = textNodes[textNodes.index(range.start)..textNodes.index(range.end)].get()
  textNodes.reduce(((acc, next) -> acc += next.nodeValue), "")

this.DateToISO8601String = (format=6, offset) ->
  ###
  accepted values for the format [1-6]:
   1 Year:
     YYYY (eg 1997)
   2 Year and month:
     YYYY-MM (eg 1997-07)
   3 Complete date:
     YYYY-MM-DD (eg 1997-07-16)
   4 Complete date plus hours and minutes:
     YYYY-MM-DDThh:mmTZD (eg 1997-07-16T19:20+01:00)
   5 Complete date plus hours, minutes and seconds:
     YYYY-MM-DDThh:mm:ssTZD (eg 1997-07-16T19:20:30+01:00)
   6 Complete date plus hours, minutes, seconds and a decimal
     fraction of a second
     YYYY-MM-DDThh:mm:ss.sTZD (eg 1997-07-16T19:20:30.45+01:00)
  ###
  if not offset
    offset = 'Z'
    date = this
  else
    d = offset.match(/([-+])([0-9]{2}):([0-9]{2})/)
    offsetnum = (Number(d[2]) * 60) + Number(d[3])
    offsetnum *= if d[1] is '-' then -1 else 1
    date = new Date(Number(Number(this) + (offsetnum * 60000)))

  zeropad = (num) -> (if num < 10 then '0' else '') + num

  str = ""
  str += date.getUTCFullYear()
  if format > 1
    str += "-" + zeropad(date.getUTCMonth() + 1)
  if format > 2
    str += "-" + zeropad(date.getUTCDate())
  if format > 3
    str += "T" + zeropad(date.getUTCHours()) + ":" + zeropad(date.getUTCMinutes())

  if format > 5
    secs = Number(date.getUTCSeconds() + "." + (if date.getUTCMilliseconds() < 100 then '0' else '') + zeropad(date.getUTCMilliseconds()))
    str += ":" + zeropad(secs)
  else if format > 4
    str += ":" + zeropad(date.getUTCSeconds())

  if format > 3
    str += offset

  str

# Ajax fixtures helpers

fixtureElem = document.getElementById('fixtures')
fixtureMemo = {}

this.setFixtureElem = (elem) ->
  fixtureElem = elem

this.fix = ->
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

this.clearFixtures = ->
  $(fixtureElem).empty()
