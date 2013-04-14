class MockPlugin
  constructor: ->
  pluginInit: ->

describe 'Annotator::setupPlugins', ->
  annotator = null
  $fix = null

  beforeEach ->
    for p in ['AnnotateItPermissions', 'Auth', 'Markdown', 'Store', 'Tags', 'Unsupported']
      Annotator.Plugin[p] = MockPlugin

    addFixture('kitchensink')
    $fix = $(fix())

  afterEach -> clearFixtures()

  it 'should added to the Annotator prototype', ->
    assert.equal(typeof Annotator::setupPlugins, 'function')

  it 'should be callable via jQuery.fn.Annotator', ->
    sinon.spy(Annotator.prototype, 'setupPlugins')

    $fix.annotator().annotator('setupPlugins', {}, {Filter: {appendTo: fix()}})
    assert(Annotator::setupPlugins.calledOnce)

  describe 'called with no parameters', ->
    _Showdown = null

    beforeEach ->
      _Showdown = window.Showdown
      annotator = new Annotator(fix())
      annotator.setupPlugins({}, {Filter: {appendTo: fix()}})

    afterEach -> window.Showdown = _Showdown

    describe 'it includes the Unsupported plugin', ->
      it 'should add the Unsupported plugin by default', ->
        assert.isDefined(annotator.plugins.Unsupported)

    describe 'it includes the Tags plugin', ->
      it 'should add the Tags plugin by default', ->
        assert.isDefined(annotator.plugins.Tags)

    describe 'it includes the Filter plugin', ->
      filterPlugin = null

      beforeEach -> filterPlugin = annotator.plugins.Filter

      it 'should add the Filter plugin by default', ->
        assert.isDefined(filterPlugin)

      it 'should have filters for annotations, tags and users', ->
        expectedFilters = ['text', 'user', 'tags']
        for filter in expectedFilters
          assert.isTrue(filter in (f.property for f in filterPlugin.filters))

    describe 'and with Showdown loaded in the page', ->
      it 'should add the Markdown plugin', ->
        assert.isDefined(annotator.plugins.Markdown)

  describe 'called with AnnotateIt config', ->
    beforeEach ->
      # Prevent store making initial AJAX requests.
      sinon.stub(Annotator.Plugin.Store.prototype, 'pluginInit')

      annotator = new Annotator(fix())
      annotator.setupPlugins()

    afterEach ->
      Annotator.Plugin.Store.prototype.pluginInit.restore()

    it 'should add the Store plugin', ->
      assert.isDefined(annotator.plugins.Store)

    it 'should add the AnnotateItPermissions plugin', ->
      assert.isDefined(annotator.plugins.AnnotateItPermissions)

    it 'should add the Auth plugin', ->
      assert.isDefined(annotator.plugins.Auth)

  describe 'called with plugin options', ->
    beforeEach -> annotator = new Annotator(fix())

    it 'should override default plugin options', ->
      annotator.setupPlugins null,
        AnnotateItPermissions: false
        Filter:
          filters: null
          addAnnotationFilter: false
          appendTo: fix()

      assert.lengthOf(annotator.plugins.Filter.filters, 0)

    it 'should NOT load a plugin if its key is set to null OR false', ->
      annotator.setupPlugins null, {Filter: false, Tags: null}
      assert.isUndefined(annotator.plugins.Tags)
      assert.isUndefined(annotator.plugins.Filter)
