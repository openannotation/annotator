BackboneEvents = require('backbone-events-standalone')
h = require('helpers')
Viewer = require('../../../src/plugin/viewer')
Util = require('../../../src/util')
$ = Util.$

describe 'Viewer plugin', ->
  elem = null
  core = null
  plugin = null

  beforeEach ->
    h.addFixture('viewer')
    elem = h.fix()
    core = {}
    BackboneEvents.mixin(core)

  afterEach ->
    h.clearFixtures()

  describe 'in default configuration', ->

    beforeEach ->
      plugin = new Viewer(elem)
      plugin.configure({core: core})
      plugin.pluginInit()

    afterEach ->
      plugin.destroy()

    it 'should start hidden', ->
      assert.isFalse(plugin.isShown())

    it 'should display an external link if the annotation provides one', ->
      plugin.load([{
        links: [
          {rel: "alternate", href: "http://example.com/foo", type: "text/html"}
        ]
      }])

      assert.equal(
        $(plugin.widget).find('.annotator-link').attr('href'),
        'http://example.com/foo'
      )

    describe '.show()', ->
      it 'should make the viewer widget visible', ->
        plugin.show()
        assert.isTrue(plugin.isShown())

      it 'should use the interactionPoint set on the core object to set its
          position, if available', ->
        core.interactionPoint = {
          top: '100px'
          left: '200px'
        }
        plugin.show()
        assert.deepEqual(
          {
            top: plugin.widget.style.top
            left: plugin.widget.style.left
          },
          core.interactionPoint
        )


    describe '.hide()', ->
      it 'should hide the viewer widget', ->
        plugin.show()
        plugin.hide()
        assert.isFalse(plugin.isShown())


    describe '.destroy()', ->
      it 'should remove the viewer from the document', ->
        plugin.destroy()
        assert.isFalse(document.body in $(plugin.widget).parents())


    describe '.load(annotations)', ->

      it 'should show the widget', ->
        plugin.load([{text: "Hello, world."}])
        assert.isTrue(plugin.isShown())

      it 'should show the annotation text (one annotation)', ->
        plugin.load([{text: "Hello, world."}])
        assert.isTrue($(plugin.widget).html().indexOf("Hello, world.") >= 0)

      it 'should show the annotation text (multiple annotations)', ->
        plugin.load([
          {text: "Penguins with hats"}
          {text: "Elephants with scarves"}
        ])
        html = $(plugin.widget).html()
        assert.isTrue(html.indexOf("Penguins with hats") >= 0)
        assert.isTrue(html.indexOf("Elephants with scarves") >= 0)


    describe 'custom fields', ->
      ann = null
      field = null

      beforeEach ->
        ann = {text: "Donkeys with beachballs"}
        field = {load: sinon.spy()}
        plugin.addField(field)

      it 'should call the load callback of added fields when the viewer is
          shown', ->
        plugin.load([ann])
        sinon.assert.calledOnce(field.load)

      it 'should pass a DOM Node as the first argument to the load callback', ->
        plugin.load([ann])
        callArgs = field.load.args[0]
        assert.equal(callArgs[0].nodeType, 1)

      it 'should pass an annotation as the second argument to the load
          callback', ->
        plugin.load([ann])
        callArgs = field.load.args[0]
        assert.equal(callArgs[1], ann)

      it 'should call the load callback once per annotation', ->
        ann2 = {text: "Sharks with laserbeams"}
        plugin.load([ann, ann2])
        assert.equal(field.load.callCount, 2)

      it 'should insert the field elements into the viewer', ->
        plugin.load([ann])
        callArgs = field.load.args[0]
        assert.isTrue(plugin.widget in $(callArgs[0]).parents())


  describe 'with the readOnly option set to true', ->

    beforeEach ->
      plugin = new Viewer(elem)
      plugin.configure({core: core})
      plugin.pluginInit()

    afterEach ->
      plugin.destroy()


  describe 'with the showEditButton option set to true', ->

    beforeEach ->
      plugin = new Viewer(elem, {
        showEditButton: true
      })
      plugin.configure({core: core})
      plugin.pluginInit()

    afterEach ->
      plugin.destroy()

    it 'should contain an edit button', ->
      plugin.load([{text: "Anteaters with torches"}])
      assert($(plugin.widget).find('.annotator-edit'))

    it 'should pass a controller for the edit button as the third argument to
        the load callback of custom fields', ->
      field = {load: sinon.spy()}
      plugin.addField(field)
      plugin.load([{text: "Bees with wands"}])
      callArgs = field.load.args[0]
      assert.property(callArgs[2], 'showEdit')
      assert.property(callArgs[2], 'hideEdit')

    it 'clicking on the edit button should trigger an annotation update', ->
      ann = {text: "Rabbits with cloaks"}
      plugin.load([ann])
      core.annotations = {update: sinon.spy()}
      $(plugin.widget).find('.annotator-edit').click()
      sinon.assert.calledWith(core.annotations.update, ann)


  describe 'with the showDeleteButton option set to true', ->

    beforeEach ->
      plugin = new Viewer(elem, {
        showDeleteButton: true
      })
      plugin.configure({core: core})
      plugin.pluginInit()

    afterEach ->
      plugin.destroy()

    it 'should contain an delete button', ->
      plugin.load([{text: "Anteaters with torches"}])
      assert($(plugin.widget).find('.annotator-delete'))

    it 'should pass a controller for the edit button as the third argument to
        the load callback of custom fields', ->
      field = {load: sinon.spy()}
      plugin.addField(field)
      plugin.load([{text: "Bees with wands"}])
      callArgs = field.load.args[0]
      assert.property(callArgs[2], 'showDelete')
      assert.property(callArgs[2], 'hideDelete')

    it 'clicking on the delete button should trigger an annotation delete', ->
      ann = {text: "Rabbits with cloaks"}
      plugin.load([ann])
      core.annotations = {delete: sinon.spy()}
      $(plugin.widget).find('.annotator-delete').click()
      sinon.assert.calledWith(core.annotations.delete, ann)


  describe 'with the defaultFields option set to false', ->

    beforeEach ->
      plugin = new Viewer(elem, {
        defaultFields: false
      })
      plugin.configure({core: core})
      plugin.pluginInit()

    afterEach ->
      plugin.destroy()

    it 'should not add the default fields', ->
      plugin.load([{text: "Anteaters with torches"}])
      assert.equal(
        $(plugin.widget).html().indexOf("Anteaters with torches"),
        -1
      )

  describe 'event handlers', ->
    hl = null
    clock = null

    beforeEach ->
      plugin = new Viewer(elem, {
        activityDelay: 50,
        inactivityDelay: 200
      })
      plugin.configure({core: core})
      plugin.pluginInit()
      hl = $(elem).find('.annotator-hl.one')
      hl.data('annotation', {text: "Cats with mats"})
      clock = sinon.useFakeTimers()

    afterEach ->
      clock.restore()
      plugin.destroy()

    it 'should show annotations when a user mouses over a highlight within
        its element', ->
      hl.mouseover()
      assert.isTrue(plugin.isShown())
      assert.isTrue($(plugin.widget).html().indexOf("Cats with mats") >= 0)

    it 'should redraw the viewer when another highlight is moused over, but
        only after a short delay (the activityDelay)', ->
      hl2 = $(elem).find('.annotator-hl.two')
      hl2.data('annotation', {text: "Dogs with bones"})
      hl.mouseover()
      hl2.mouseover()
      clock.tick(49)
      assert.isTrue($(plugin.widget).html().indexOf("Cats with mats") >= 0)
      clock.tick(2)
      assert.equal($(plugin.widget).html().indexOf("Cats with mats"), -1)
      assert.isTrue($(plugin.widget).html().indexOf("Dogs with bones") >= 0)

    it 'should hide the viewer when the user mouses off the highlight, after a
        delay (the inactivityDelay)', ->
      hl.mouseover()
      hl.mouseleave()
      clock.tick(199)
      assert.isTrue(plugin.isShown())
      clock.tick(2)
      assert.isFalse(plugin.isShown())

    it 'should prevent the viewer from hiding if the user mouses over the
        viewer', ->
      hl.mouseover()
      hl.mouseleave()
      clock.tick(199)
      $(plugin.widget).mouseenter()
      clock.tick(100)
      assert.isTrue(plugin.isShown())

    it 'should hide the viewer when the user mouses off the viewer, after a
        delay (the inactivityDelay)', ->
      hl.mouseover()
      hl.mouseleave()
      clock.tick(199)
      $(plugin.widget).mouseenter()
      $(plugin.widget).mouseleave()
      clock.tick(199)
      assert.isTrue(plugin.isShown())
      clock.tick(2)
      assert.isFalse(plugin.isShown())
