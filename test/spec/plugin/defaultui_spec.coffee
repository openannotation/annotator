h = require('helpers')
$ = require('../../../src/util').$

DefaultUI = require('../../../src/plugin/defaultui').DefaultUI


describe 'DefaultUI plugin', ->

  it 'should add CSS to the document that ensures annotator elements have a
      suitably high z-index', ->

    h.addFixture 'annotator'
    $fix = $(h.fix())
    $fix.show()

    $adder = $(
      '<div style="position:relative;" class="annotator-adder">&nbsp;</div>'
    ).appendTo($fix)
    $filter = $(
      '<div style="position:relative;" class="annotator-filter">&nbsp;</div>'
    ).appendTo($fix)

    check = (minimum) ->
      adderZ = parseInt($adder.css('z-index'), 10)
      filterZ = parseInt($filter.css('z-index'), 10)
      assert.operator(adderZ, '>', minimum)
      assert.operator(filterZ, '>', minimum)
      assert.operator(adderZ, '>', filterZ)

    plug = DefaultUI(h.fix())(null)
    check(1000)

    $fix.append('<div style="position: relative; z-index: 2000"></div>')
    plug = DefaultUI(h.fix())(null)
    check(2000)

  it "should remove its elements from the page when destroyed", ->
    el = $('<div></div>')[0]
    plug = DefaultUI(el)(null)
    plug.destroy()
    assert.equal($(el).find('[class^=annotator-]').length, 0)
