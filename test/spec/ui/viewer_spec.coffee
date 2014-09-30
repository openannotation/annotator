h = require('helpers')
Range = require('xpath-range').Range

UI = require('../../../src/ui')
Util = require('../../../src/util')

$ = Util.$


describe 'UI.Viewer', ->
  v = null

  beforeEach ->
    h.addFixture('viewer')

  afterEach ->
    h.clearFixtures()

  describe 'in default configuration', ->

    beforeEach ->
      v = new UI.Viewer()

    afterEach ->
      v.destroy()

    it 'should start hidden', ->
      assert.isFalse(v.isShown())

    it 'should display an external link if the annotation provides one', ->
      v.load([{
        links: [
          {
            rel: "alternate",
            href: "http://example.com/foo",
            type: "text/html"
          },
          {
            rel: "default",
            href: "http://example.com/foo2",
            type: "application/pdf"
          },
          {
            rel: "alternate",
            href: "http://example.com/foo3",
            type: "text/html"
          },
          {
            rel: "default",
            href: "http://example.com/foo4",
            type: "text/html"
          },
          {
            rel: "alternate",
            href: "http://example.com/foo5",
            type: "application/pdf"
          },
        ]
      }])

      assert.equal(
        v.element.find('.annotator-link').attr('href'),
        'http://example.com/foo'
      )

    it "should not display an external link if the annotation doesn't
        provide a valid one", ->
      v.load([{
        links: [
          {
            rel: "default",
            href: "http://example.com/foo2",
            type: "application/pdf"
          },
          {
            rel: "default",
            href: "http://example.com/foo4",
            type: "text/html"
          },
          {
            rel: "alternate",
            href: "http://example.com/foo5",
            type: "application/pdf"
          },
        ]
      }])

      assert.isUndefined(
        v.element.find('.annotator-link').attr('href')
      )

    describe '.show()', ->
      it 'should make the viewer widget visible', ->
        v.show()
        assert.isTrue(v.isShown())

      it 'sets the widget position if a position is provided', ->
        position = {
          top: '100px'
          left: '200px'
        }
        v.show(position)
        assert.deepEqual(
          {
            top: v.element[0].style.top
            left: v.element[0].style.left
          },
          position
        )


    describe '.hide()', ->
      it 'should hide the viewer widget', ->
        v.show()
        v.hide()
        assert.isFalse(v.isShown())


    describe '.destroy()', ->
      it 'should remove the viewer from the document', ->
        v.destroy()
        assert.isFalse(document.body in v.element.parents())


    describe '.load(annotations)', ->

      it 'should show the widget', ->
        v.load([{text: "Hello, world."}])
        assert.isTrue(v.isShown())

      it 'should show the annotation text (one annotation)', ->
        v.load([{text: "Hello, world."}])
        assert.isTrue(v.element.html().indexOf("Hello, world.") >= 0)

      it 'should show the annotation text (multiple annotations)', ->
        v.load([
          {text: "Penguins with hats"}
          {text: "Elephants with scarves"}
        ])
        html = v.element.html()
        assert.isTrue(html.indexOf("Penguins with hats") >= 0)
        assert.isTrue(html.indexOf("Elephants with scarves") >= 0)


    describe 'custom fields', ->
      ann = null
      field = null

      beforeEach ->
        ann = {text: "Donkeys with beachballs"}
        field = {load: sinon.spy()}
        v.addField(field)

      it 'should call the load callback of added fields when annotations are
          loaded into the viewer', ->
        v.load([ann])
        sinon.assert.calledOnce(field.load)

      it 'should pass a DOM Node as the first argument to the load callback', ->
        v.load([ann])
        callArgs = field.load.args[0]
        assert.equal(callArgs[0].nodeType, 1)

      it 'should pass an annotation as the second argument to the load
          callback', ->
        v.load([ann])
        callArgs = field.load.args[0]
        assert.equal(callArgs[1], ann)

      it 'should call the load callback once per annotation', ->
        ann2 = {text: "Sharks with laserbeams"}
        v.load([ann, ann2])
        assert.equal(field.load.callCount, 2)

      it 'should insert the field elements into the viewer', ->
        v.load([ann])
        callArgs = field.load.args[0]
        assert.isTrue(v.element[0] in $(callArgs[0]).parents())


  describe 'with the showEditButton option set to true', ->
    onEdit = null

    beforeEach ->
      onEdit = sinon.stub()
      v = new UI.Viewer({
        showEditButton: true
        onEdit: onEdit
      })

    afterEach ->
      v.destroy()

    it 'should contain an edit button', ->
      v.load([{text: "Anteaters with torches"}])
      assert(v.element.find('.annotator-edit'))

    it 'should pass a controller for the edit button as the third argument to
        the load callback of custom fields', ->
      field = {load: sinon.spy()}
      v.addField(field)
      v.load([{text: "Bees with wands"}])
      callArgs = field.load.args[0]
      assert.property(callArgs[2], 'showEdit')
      assert.property(callArgs[2], 'hideEdit')

    it 'clicking on the edit button should trigger the onEdit callback', ->
      ann = {text: "Rabbits with cloaks"}
      v.load([ann])
      v.element.find('.annotator-edit').click()
      sinon.assert.calledWith(onEdit, ann)


  describe 'with the showDeleteButton option set to true', ->
    onDelete = null

    beforeEach ->
      onDelete = sinon.stub()
      v = new UI.Viewer({
        showDeleteButton: true
        onDelete: onDelete
      })

    afterEach ->
      v.destroy()

    it 'should contain an delete button', ->
      v.load([{text: "Anteaters with torches"}])
      assert(v.element.find('.annotator-delete'))

    it 'should pass a controller for the edit button as the third argument to
        the load callback of custom fields', ->
      field = {load: sinon.spy()}
      v.addField(field)
      v.load([{text: "Bees with wands"}])
      callArgs = field.load.args[0]
      assert.property(callArgs[2], 'showDelete')
      assert.property(callArgs[2], 'hideDelete')

    it 'clicking on the delete button should trigger an annotation delete', ->
      ann = {text: "Rabbits with cloaks"}
      v.load([ann])
      v.element.find('.annotator-delete').click()
      sinon.assert.calledWith(onDelete, ann)


  describe 'with the defaultFields option set to false', ->

    beforeEach ->
      v = new UI.Viewer({
        defaultFields: false
      })

    afterEach ->
      v.destroy()

    it 'should not add the default fields', ->
      v.load([{text: "Anteaters with torches"}])
      assert.equal(
        v.element.html().indexOf("Anteaters with torches"),
        -1
      )

  describe 'event handlers', ->
    hl = null
    clock = null

    beforeEach ->
      v = new UI.Viewer({
        activityDelay: 50,
        inactivityDelay: 200,
        autoViewHighlights: h.fix()
      })
      hl = $(h.fix()).find('.annotator-hl.one')
      hl.data('annotation', {text: "Cats with mats"})
      clock = sinon.useFakeTimers()

    afterEach ->
      clock.restore()
      v.destroy()

    it 'should show annotations when a user mouses over a highlight within
        its element', ->
      hl.mouseover()
      assert.isTrue(v.isShown())
      assert.isTrue(v.element.html().indexOf("Cats with mats") >= 0)

    it 'should redraw the viewer when another highlight is moused over, but
        only after a short delay (the activityDelay)', ->
      hl2 = $(h.fix()).find('.annotator-hl.two')
      hl2.data('annotation', {text: "Dogs with bones"})
      hl.mouseover()
      hl2.mouseover()
      clock.tick(49)
      assert.isTrue(v.element.html().indexOf("Cats with mats") >= 0)
      clock.tick(2)
      assert.equal(v.element.html().indexOf("Cats with mats"), -1)
      assert.isTrue(v.element.html().indexOf("Dogs with bones") >= 0)

    it 'should hide the viewer when the user mouses off the highlight, after a
        delay (the inactivityDelay)', ->
      hl.mouseover()
      hl.mouseleave()
      clock.tick(199)
      assert.isTrue(v.isShown())
      clock.tick(2)
      assert.isFalse(v.isShown())

    it 'should prevent the viewer from hiding if the user mouses over the
        viewer', ->
      hl.mouseover()
      hl.mouseleave()
      clock.tick(199)
      v.element.mouseenter()
      clock.tick(100)
      assert.isTrue(v.isShown())

    it 'should hide the viewer when the user mouses off the viewer, after a
        delay (the inactivityDelay)', ->
      hl.mouseover()
      hl.mouseleave()
      clock.tick(199)
      v.element.mouseenter()
      v.element.mouseleave()
      clock.tick(199)
      assert.isTrue(v.isShown())
      clock.tick(2)
      assert.isFalse(v.isShown())

    # Regression test: Issue #431
    it 'should not interfere with other mouseup and mousedown handlers on
        the document', ->
      doc = h.fix().ownerDocument
      called = false
      $(doc)
        .on('mouseup', -> called = true)
        .on('mousedown', -> called = true)
      $(doc.body).trigger({type: 'mouseup', which: 2})
      assert.isTrue(called, 'event should have propagated to the document')
      called = false
      $(doc.body).trigger({type: 'mousedown', which: 2})
      assert.isTrue(called, 'event should have propagated to the document')
