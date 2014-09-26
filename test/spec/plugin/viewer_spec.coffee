Viewer = require('../../../src/plugin/viewer').Viewer


describe 'Viewer plugin', ->
  ann = null
  mockRegistry = null
  mockViewer = null
  mockViewerCtor = null
  sandbox = null

  beforeEach ->
    sandbox = sinon.sandbox.create()

    mockRegistry = {
      annotations: {
        update: sandbox.stub()
        delete: sandbox.stub()
      }
    }

    mockViewer = {
      destroy: sandbox.stub()
    }
    mockViewerCtor = sandbox.stub()
    mockViewerCtor.returns(mockViewer)

  afterEach ->
    sandbox.restore()

  it 'sets a default onEdit handler that calls the storage update function', ->
    plugin = Viewer({}, mockViewerCtor)(mockRegistry)

    passedOptions = mockViewerCtor.firstCall.args[0]
    assert(sinon.match.has('onEdit').test(passedOptions))

    passedOptions.onEdit({text: 'foo'})
    sinon.assert.calledWith(mockRegistry.annotations.update, {text: 'foo'})

  it 'sets a default onDelete handler that calls the storage delete
      function', ->
    plugin = Viewer({}, mockViewerCtor)(mockRegistry)

    passedOptions = mockViewerCtor.firstCall.args[0]
    assert(sinon.match.has('onDelete').test(passedOptions))

    passedOptions.onDelete({text: 'foo'})
    sinon.assert.calledWith(mockRegistry.annotations.delete, {text: 'foo'})

  it 'destroys the viewer component when destroyed', ->
    plugin = Viewer({}, mockViewerCtor)(mockRegistry)
    plugin.onDestroy()
    sinon.assert.calledOnce(mockViewer.destroy)
