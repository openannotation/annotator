Highlighter = require('../../../src/plugin/highlighter').Highlighter


describe 'Highlighter plugin', ->
  ann = null
  mockElement = null
  mockHighlighter = null
  plugin = null
  sandbox = null

  beforeEach ->
    sandbox = sinon.sandbox.create()

    ann = {
      id: 'abc123'
      ranges: [{
        start: '/p[1]'
        startOffset: 0
        end: '/p[1]'
        endOffset: 12
      }]
    }

    mockElement = {}

    mockHighlighter = {
      draw: sandbox.stub()
      undraw: sandbox.stub()
      redraw: sandbox.stub()
      drawAll: sandbox.stub()
      destroy: sandbox.stub()
    }
    mockHighlighterCtor = sandbox.stub()
    mockHighlighterCtor.returns(mockHighlighter)

    # Create a new plugin object. The Highlighter plugin doesn't use the
    # registry, so we can just pass null.
    plugin = Highlighter(mockElement, {}, mockHighlighterCtor)(null)

  afterEach ->
    sandbox.restore()

  it 'should draw highlights onAnnotationCreated', ->
    plugin.onAnnotationCreated(ann)
    sinon.assert.calledWith(mockHighlighter.draw, ann)

  it 'should redraw highlights onAnnotationUpdated', ->
    plugin.onAnnotationUpdated(ann)
    sinon.assert.calledWith(mockHighlighter.redraw, ann)

  it 'should undraw highlights onAnnotationDeleted', ->
    plugin.onAnnotationDeleted(ann)
    sinon.assert.calledWith(mockHighlighter.undraw, ann)

  it 'should draw all highlights onAnnotationsLoaded', ->
    ann2 = {
      id: 'def456'
      ranges: [{
        start: '/p[2]'
        startOffset: 0
        end: '/p[2]'
        endOffset: 20
      }]
    }
    plugin.onAnnotationsLoaded([ann, ann2])
    sinon.assert.calledWith(mockHighlighter.drawAll, [ann, ann2])

  it 'destroys the highlighter component when destroyed', ->
    plugin.destroy()
    sinon.assert.calledOnce(mockHighlighter.destroy)
