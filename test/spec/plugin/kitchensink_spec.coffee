describe 'Annotator::setupPlugins', ->
  annotator = null

  beforeEach ->
    window.location = {href: 'http://www.example.com'}
    this.addMatchers
      toHaveFilter: (prop) -> prop in (f.property for f in this.actual.filters)

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
        expect(filterPlugin).toHaveFilter(filter) for filter in expectedFilters

    describe 'and with Showdown loaded in the page', ->
      it 'should add the Markdown plugin', ->
        expect(annotator.plugins.Markdown).toBeDefined()

  describe 'called with AnnotateIt config', ->
    beforeEach ->
      # Prevent store making initial AJAX requests.
      spyOn Annotator.Plugin.Store.prototype, 'pluginInit'

      annotator = new Annotator $('<div />')[0]
      annotator.setupPlugins
        userId:    'bill'
        userName:  'Bill'
        accountId: 'some-fake-id'
        authToken: 'another-fake-token'

    describe 'it includes the Store plugin', ->
      it 'should add the Store plugin', ->
        expect(annotator.plugins.Store).toBeDefined()

    describe 'it includes the Permissions plugin', ->
      it 'should add the Permissions plugin', ->
        expect(annotator.plugins.Permissions).toBeDefined()

    describe 'it includes the Auth headers', ->
      it 'should add custom headers to the Annotator @element', ->
        expect(annotator.element.data('annotator:headers')).toEqual
          'X-Annotator-User-Id':    'bill'
          'X-Annotator-Account-Id': 'some-fake-id'
          'X-Annotator-Auth-Token': 'another-fake-token'
