describe 'Annotator::setupPlugins', ->
  annotator = null

  beforeEach ->
    window.location = {href: 'http://www.example.com'}
    this.addMatchers
      toContainFilter: (prop) -> prop in (f.property for f in this.actual.filters)

  it 'should added to the Annotator prototype', ->
    expect(typeof Annotator::setupPlugins).toBe('function')

  it 'should be callable via jQuery.fn.Annotator', ->
    spyOn Annotator.prototype, 'setupPlugins'

    $('<div />').annotator().annotator('setupPlugins')
    expect(Annotator::setupPlugins).toHaveBeenCalled()

  describe 'called with no parameters', ->
    _Showdown = null

    beforeEach ->
      _Showdown = window.Showdown
      annotator = new Annotator $('<div />')[0]
      annotator.setupPlugins()

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

      annotator = new Annotator $('<div />')[0]
      annotator.setupPlugins()


  it 'should add the Store plugin', ->
    expect(annotator.plugins.Store).toBeDefined()

  it 'should add the Permissions plugin', ->
    expect(annotator.plugins.Permissions).toBeDefined()

  it 'should add the Auth plugin', ->
    expect(annotator.plugins.Auth).toBeDefined()


  describe 'called with plugin options', ->
    beforeEach -> annotator = new Annotator $('<div />')[0]

    it 'should override default plugin options', ->
      annotator.setupPlugins null,
        Filter:
          filters: []
          addAnnotationFilter: false

      expect(annotator.plugins.Filter.filters.length).toBe(0)

    it 'should NOT load a plugin if it\'s key is set to null OR false', ->
      annotator.setupPlugins null, {Filter: false, Tags: null}
      expect(annotator.plugins.Tags).not.toBeDefined()
      expect(annotator.plugins.Filter).not.toBeDefined()
