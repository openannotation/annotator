describe 'Annotator::setupPlugins', ->
  annotator = null
  $fix = null

  beforeEach ->
    addFixture('kitchensink')
    $fix = $(fix())
    this.addMatchers
      toContainFilter: (prop) -> prop in (f.property for f in this.actual.filters)

  afterEach -> clearFixtures()

  it 'should added to the Annotator prototype', ->
    expect(typeof Annotator::setupPlugins).toBe('function')

  it 'should be callable via jQuery.fn.Annotator', ->
    spyOn Annotator.prototype, 'setupPlugins'

    $fix.annotator().annotator('setupPlugins', {}, {Filter: {appendTo: fix()}})
    expect(Annotator::setupPlugins).toHaveBeenCalled()

  describe 'called with no parameters', ->
    _Showdown = null

    beforeEach ->
      _Showdown = window.Showdown
      annotator = new Annotator(fix())
      annotator.setupPlugins({}, {Filter: {appendTo: fix()}})

    afterEach -> window.Showdown = _Showdown

    describe 'it includes the Unsupported plugin', ->
      it 'should add the Unsupported plugin by default', ->
        expect(annotator.plugins.Unsupported).toBeDefined()

    describe 'it includes the Tags plugin', ->
      it 'should add the Tags plugin by default', ->
        expect(annotator.plugins.Tags).toBeDefined()

    describe 'it includes the Filter plugin', ->
      filterPlugin = null

      beforeEach -> filterPlugin = annotator.plugins.Filter

      it 'should add the Filter plugin by default', ->
        expect(filterPlugin).toBeDefined()

      it 'should have a filters for annotations, tags and users', ->
        expectedFilters = ['text', 'user', 'tags']
        expect(filterPlugin).toContainFilter(filter) for filter in expectedFilters

    describe 'and with Showdown loaded in the page', ->
      it 'should add the Markdown plugin', ->
        expect(annotator.plugins.Markdown).toBeDefined()

  describe 'called with AnnotateIt config', ->
    beforeEach ->
      # Prevent store making initial AJAX requests.
      spyOn Annotator.Plugin.Store.prototype, 'pluginInit'

      annotator = new Annotator(fix())
      annotator.setupPlugins()

  it 'should add the Store plugin', ->
    expect(annotator.plugins.Store).toBeDefined()

  it 'should add the AnnotateItPermissions plugin', ->
    expect(annotator.plugins.AnnotateItPermissions).toBeDefined()

  it 'should add the Auth plugin', ->
    expect(annotator.plugins.Auth).toBeDefined()

  describe 'called with plugin options', ->
    beforeEach -> annotator = new Annotator(fix())

    it 'should override default plugin options', ->
      annotator.setupPlugins null,
        AnnotateItPermissions: false
        Filter:
          filters: null
          addAnnotationFilter: false
          appendTo: fix()

      expect(annotator.plugins.Filter.filters.length).toBe(0)

    it 'should NOT load a plugin if its key is set to null OR false', ->
      annotator.setupPlugins null, {Filter: false, Tags: null}
      expect(annotator.plugins.Tags).not.toBeDefined()
      expect(annotator.plugins.Filter).not.toBeDefined()
