BackboneEvents = require('backbone-events-standalone')
h = require('helpers')
Viewer = require('../../../src/plugin/viewer')
Util = require('../../../src/util')
$ = Util.$

describe 'Viewer plugin', ->
  core = null
  plugin = null

  beforeEach ->
    h.addFixture('viewer')
    core = {element: $(h.fix())}
    BackboneEvents.mixin(core)

  afterEach ->
    h.clearFixtures()

  describe 'in default configuration', ->

    beforeEach ->
      plugin = new Viewer()
      plugin.core = core
      core.editor = plugin
      plugin.pluginInit()

    afterEach ->
      plugin.destroy()

    it 'should start hidden', ->
      assert.isFalse(plugin.isShown())

    it 'should display an external link if the annotation provides one', ->
      plugin.load([{
        links: [
          {rel: "alternate", href: "http://example.com/foo", type: "text/html"},
          {rel: "default", href: "http://example.com/foo2", type: "application/pdf"},
          {rel: "alternate", href: "http://example.com/foo3", type: "text/html"},
          {rel: "default", href: "http://example.com/foo4", type: "text/html"},
          {rel: "alternate", href: "http://example.com/foo5", type: "application/pdf"},
        ]
      }])

      assert.equal(
        plugin.element.find('.annotator-link').attr('href'),
        'http://example.com/foo'
      )

    it 'should not display an external link if the annotation doesn\'t provide a valid one', ->
      plugin.load([{
        links: [
          {rel: "default", href: "http://example.com/foo2", type: "application/pdf"},
          {rel: "default", href: "http://example.com/foo4", type: "text/html"},
          {rel: "alternate", href: "http://example.com/foo5", type: "application/pdf"},
        ]
      }])

      assert.isUndefined(
        plugin.element.find('.annotator-link').attr('href')
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
            top: plugin.element[0].style.top
            left: plugin.element[0].style.left
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
        assert.isFalse(document.body in plugin.element.parents())


    describe '.load(annotations)', ->

      it 'should show the widget', ->
        plugin.load([{text: "Hello, world."}])
        assert.isTrue(plugin.isShown())

      it 'should show the annotation text (one annotation)', ->
        plugin.load([{text: "Hello, world."}])
        assert.isTrue(plugin.element.html().indexOf("Hello, world.") >= 0)

      it 'should show the annotation text (multiple annotations)', ->
        plugin.load([
          {text: "Penguins with hats"}
          {text: "Elephants with scarves"}
        ])
        html = plugin.element.html()
        assert.isTrue(html.indexOf("Penguins with hats") >= 0)
        assert.isTrue(html.indexOf("Elephants with scarves") >= 0)


    describe 'custom fields', ->
      ann = null
      field = null

      beforeEach ->
        ann = {text: "Donkeys with beachballs"}
        field = {load: sinon.spy()}
        plugin.addField(field)

      it 'should call the load callback of added fields when annotations are
          loaded into the viewer', ->
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
        assert.isTrue(plugin.element[0] in $(callArgs[0]).parents())


  describe 'with the readOnly option set to true', ->

    beforeEach ->
      plugin = new Viewer()
      plugin.core = core
      core.editor = plugin
      plugin.pluginInit()

    afterEach ->
      plugin.destroy()


  describe 'with the showEditButton option set to true', ->

    beforeEach ->
      plugin = new Viewer({
        showEditButton: true
      })
      plugin.core = core
      core.editor = plugin
      plugin.pluginInit()

    afterEach ->
      plugin.destroy()

    it 'should contain an edit button', ->
      plugin.load([{text: "Anteaters with torches"}])
      assert(plugin.element.find('.annotator-edit'))

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
      plugin.element.find('.annotator-edit').click()
      sinon.assert.calledWith(core.annotations.update, ann)


  describe 'with the showDeleteButton option set to true', ->

    beforeEach ->
      plugin = new Viewer({
        showDeleteButton: true
      })
      plugin.core = core
      core.editor = plugin
      plugin.pluginInit()

    afterEach ->
      plugin.destroy()

    it 'should contain an delete button', ->
      plugin.load([{text: "Anteaters with torches"}])
      assert(plugin.element.find('.annotator-delete'))

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
      plugin.element.find('.annotator-delete').click()
      sinon.assert.calledWith(core.annotations.delete, ann)


  describe 'with the defaultFields option set to false', ->

    beforeEach ->
      plugin = new Viewer({
        defaultFields: false
      })
      plugin.core = core
      core.editor = plugin
      plugin.pluginInit()

    afterEach ->
      plugin.destroy()

    it 'should not add the default fields', ->
      plugin.load([{text: "Anteaters with torches"}])
      assert.equal(
        plugin.element.html().indexOf("Anteaters with torches"),
        -1
      )

  describe 'event handlers', ->
    hl = null
    clock = null

    beforeEach ->
      plugin = new Viewer({
        activityDelay: 50,
        inactivityDelay: 200
      })
      plugin.core = core
      core.editor = plugin
      plugin.pluginInit()
      hl = core.element.find('.annotator-hl.one')
      hl.data('annotation', {text: "Cats with mats"})
      clock = sinon.useFakeTimers()

    afterEach ->
      clock.restore()
      plugin.destroy()

    it 'should show annotations when a user mouses over a highlight within
        its element', ->
      hl.mouseover()
      assert.isTrue(plugin.isShown())
      assert.isTrue(plugin.element.html().indexOf("Cats with mats") >= 0)

    it 'should redraw the viewer when another highlight is moused over, but
        only after a short delay (the activityDelay)', ->
      hl2 = core.element.find('.annotator-hl.two')
      hl2.data('annotation', {text: "Dogs with bones"})
      hl.mouseover()
      hl2.mouseover()
      clock.tick(49)
      assert.isTrue(plugin.element.html().indexOf("Cats with mats") >= 0)
      clock.tick(2)
      assert.equal(plugin.element.html().indexOf("Cats with mats"), -1)
      assert.isTrue(plugin.element.html().indexOf("Dogs with bones") >= 0)

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
      plugin.element.mouseenter()
      clock.tick(100)
      assert.isTrue(plugin.isShown())

    it 'should hide the viewer when the user mouses off the viewer, after a
        delay (the inactivityDelay)', ->
      hl.mouseover()
      hl.mouseleave()
      clock.tick(199)
      plugin.element.mouseenter()
      plugin.element.mouseleave()
      clock.tick(199)
      assert.isTrue(plugin.isShown())
      clock.tick(2)
      assert.isFalse(plugin.isShown())
