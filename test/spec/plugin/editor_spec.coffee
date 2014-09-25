Editor = require('../../../src/plugin/editor').Editor


describe 'Editor plugin', ->
  ann = null
  mockEditor = null
  plugin = null
  sandbox = null

  beforeEach ->
    sandbox = sinon.sandbox.create()

    ann = {
      id: 'abc123'
      text: 'hello there'
    }

    mockEditor = {
      load: sandbox.stub().returns("a promise, honest")
      destroy: sandbox.stub()
    }
    mockEditorCtor = sandbox.stub()
    mockEditorCtor.returns(mockEditor)

    # Create a new plugin object. The Editor plugin doesn't use the
    # registry, so we can just pass null.
    plugin = Editor({}, mockEditorCtor)(null)

  afterEach ->
    sandbox.restore()

  it 'loads an annotation into the editor component
      onBeforeAnnotationCreated', ->
    result = plugin.onBeforeAnnotationCreated(ann)
    sinon.assert.calledWith(mockEditor.load, ann)
    assert.equal(result, "a promise, honest")

  it 'loads an annotation into the editor component
      onBeforeAnnotationUpdated', ->
    result = plugin.onBeforeAnnotationUpdated(ann)
    sinon.assert.calledWith(mockEditor.load, ann)
    assert.equal(result, "a promise, honest")

  it 'destroys the editor component when destroyed', ->
    plugin.destroy()
    sinon.assert.calledOnce(mockEditor.destroy)
