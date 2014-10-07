Promise = require('../../src/util').Promise

core = require('../../src/core')


PluginHelper = (reg) ->
  @registry = reg
  @destroyed = false
  @hookCalls = []
  @hookResult = undefined
  MockPlugin.lastInstance = this

PluginHelper::onDestroy = ->
  @destroyed = true

PluginHelper::onAnnotationCreated = ->
  @hookCalls.push(['onAnnotationCreated', arguments])
  return @hookResult


MockPlugin = (reg) ->
  return new PluginHelper(reg)


MockEmptyPlugin = ->
  return {}


StorageHelper = ->
  MockStorage.lastInstance = this


MockNotificationObj = {}


MockNotification = ->
  return MockNotificationObj


MockStorage = ->
  return new StorageHelper()


MockStorageAdapter = (storage, hookRunner) ->
  @storage = storage
  @hookRunner = hookRunner
  MockStorageAdapter.lastInstance = this


describe 'AnnotatorCore', ->

  describe '#addPlugin', ->
    it 'should call plugin functions with a registry', ->
      b = new core.AnnotatorCore()
      b.addPlugin(MockPlugin)
      assert.strictEqual(MockPlugin.lastInstance.registry, b.registry)

    it 'should add the plugin object to its internal list of plugins', ->
      b = new core.AnnotatorCore()
      b.addPlugin(MockPlugin)
      assert.deepEqual(b.plugins, [MockPlugin.lastInstance])


  describe '#destroy', ->
    it "should call each plugin's onDestroy function, if it has one", (done) ->
      b = new core.AnnotatorCore()
      b.addPlugin(MockPlugin)
      b.addPlugin(MockPlugin)
      b.addPlugin(MockEmptyPlugin)

      b.destroy()
        .then ->
          result = b.plugins.map (p) -> p.destroyed
          assert.deepEqual([true, true, undefined], result)
        .then(done, done)


  describe '#runHook', ->
    it 'should run the named hook handler on each plugin', ->
      b = new core.AnnotatorCore()
      b.addPlugin(MockPlugin)
      pluginOne = MockPlugin.lastInstance
      b.addPlugin(MockPlugin)
      pluginTwo = MockPlugin.lastInstance
      b.addPlugin(MockPlugin)
      pluginThree = MockPlugin.lastInstance

      # Remove the hook handler on this plugin
      delete pluginThree.onAnnotationCreated

      b.runHook('onAnnotationCreated')

      assert.deepEqual(pluginOne.hookCalls, [['onAnnotationCreated', []]])
      assert.deepEqual(pluginTwo.hookCalls, [['onAnnotationCreated', []]])

    it 'should return a promise that resolves if all the '+
       'handlers resolve', (done) ->
      b = new core.AnnotatorCore()
      b.addPlugin(MockPlugin)
      pluginOne = MockPlugin.lastInstance
      b.addPlugin(MockPlugin)
      pluginTwo = MockPlugin.lastInstance
      b.addPlugin(MockPlugin)
      pluginThree = MockPlugin.lastInstance

      pluginOne.hookResult = 123
      pluginTwo.hookResult = Promise.resolve("ok")
      delayedResolve = null
      pluginThree.hookResult = new Promise((resolve, reject) ->
        delayedResolve = resolve
      )

      ret = b.runHook('onAnnotationCreated')
      ret.then(
        -> done(),
        -> done(new Error("Promise should not have been rejected!"))
      )

      delayedResolve("finally...")

    it 'should return a promise that rejects if any handler rejects', (done) ->
      b = new core.AnnotatorCore()
      b.addPlugin(MockPlugin)
      pluginOne = MockPlugin.lastInstance
      b.addPlugin(MockPlugin)
      pluginTwo = MockPlugin.lastInstance

      pluginOne.hookResult = Promise.resolve("ok")
      delayedReject = null
      pluginTwo.hookResult = new Promise((resolve, reject) ->
        delayedReject = reject
      )

      ret = b.runHook('onAnnotationCreated')
      ret.then(
        -> done(new Error("Promise should not have been resolved!"))
        -> done(),
      )

      delayedReject("fail...")

  describe '#setNotification', ->
    it 'should set registry `notification` to the return value of the
        notification function', ->
      b = new core.AnnotatorCore()

      b.setNotification(MockNotification)
      assert.strictEqual(b.registry.notification, MockNotificationObj)

  describe '#setStorage', ->
    it 'should call the storage function', ->
      b = new core.AnnotatorCore()
      b._storageAdapterType = MockStorageAdapter

      b.setStorage(MockStorage)
      assert.ok(MockStorage.lastInstance)

    it 'should set registry `annotations` to be a storage adapter', ->
      b = new core.AnnotatorCore()
      b._storageAdapterType = MockStorageAdapter

      b.setStorage(MockStorage)
      assert.strictEqual(
        MockStorageAdapter.lastInstance,
        b.registry.annotations
      )

    it 'should pass the adapter the return value of the storage function', ->
      b = new core.AnnotatorCore()
      b._storageAdapterType = MockStorageAdapter

      b.setStorage(MockStorage)
      assert.strictEqual(
        MockStorageAdapter.lastInstance.storage,
        MockStorage.lastInstance
      )

    it 'should pass the adapter a hook runner which calls the runHook method of
        the annotator', ->
      b = new core.AnnotatorCore()
      b._storageAdapterType = MockStorageAdapter

      sinon.spy(b, 'runHook')

      b.setStorage(MockStorage)
      MockStorageAdapter.lastInstance.hookRunner('foo', [1, 2, 3])
      sinon.assert.calledWith(b.runHook, 'foo', [1, 2, 3])
      b.runHook.restore()
