describe 'Annotator', ->
  a = null
  mockSelection = null

  beforeEach ->
    addFixture('annotator')
    a = new Annotator(fix(), {})

  afterEach ->
    delete a
    clearFixtures()

  it "loads selections from the window object on checkForSelection", ->
    if /Node\.js/.test(navigator.userAgent)
      expectation = "Node selection"
    else
      expectation = "Text selection"
      spyOn(window, 'getSelection').andReturn(expectation)

    a.checkForEndSelection()
    expect(a.selection).toEqual(expectation)

  describe "dumpAnnotations", ->
    it "returns false and prints a warning if no Store plugin is active", ->
      spyOn(console, 'warn')
      expect(a.dumpAnnotations()).toBeFalsy()
      expect(console.warn).toHaveBeenCalled()

    it "returns the results of the Store plugins dumpAnnotations method", ->
      a.plugins.Store = { dumpAnnotations: -> [1,2,3] }
      expect(a.dumpAnnotations()).toEqual([1,2,3])

  describe "addPlugin", ->

    Annotator.Plugin.Foo = -> this.name = "Bar"

    it "should add and instantiate a plugin of the specified name", ->
      a.addPlugin('Foo')
      expect(a.plugins['Foo'].name).toEqual('Bar')

    it "should complain if you try and instantiate a plugin twice", ->
      spyOn(console, 'error')
      a.addPlugin('Foo')
      a.addPlugin('Foo')
      expect(a.plugins['Foo'].name).toEqual('Bar')
      expect(console.error).toHaveBeenCalled()

    it "should complain if you try and instantiate a plugin that doesn't exist", ->
      spyOn(console, 'error')
      a.addPlugin('Bar')
      expect(a.plugins['Bar']?).toBeFalsy()
      expect(console.error).toHaveBeenCalled()