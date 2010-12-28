$ = jQuery

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
