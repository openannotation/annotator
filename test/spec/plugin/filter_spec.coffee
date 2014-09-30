Filter = require('../../../src/plugin/filter').Filter


describe 'Filter plugin', ->
  ann = null
  mockFilter = null
  plugin = null
  sandbox = null

  beforeEach ->
    sandbox = sinon.sandbox.create()

    mockFilter = {
      updateHighlights: sandbox.stub()
      destroy: sandbox.stub()
    }
    mockFilterCtor = sandbox.stub()
    mockFilterCtor.returns(mockFilter)

    # Create a new plugin object. The Filter plugin doesn't use the
    # registry, so we can just pass null.
    plugin = Filter({}, mockFilterCtor)(null)

  afterEach ->
    sandbox.restore()

  for x in ['onAnnotationsLoaded',
            'onAnnotationCreated',
            'onAnnotationUpdated',
            'onAnnotationDeleted']

    it "calls updateHighlights on the filter component #{x}", ->
      result = plugin[x]({text: 123})
      sinon.assert.calledWith(mockFilter.updateHighlights)

  it 'destroys the filter component when destroyed', ->
    plugin.onDestroy()
    sinon.assert.calledOnce(mockFilter.destroy)
