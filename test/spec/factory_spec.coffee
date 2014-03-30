Factory = require('../../src/factory')

class MockAnnotatorSimple
class MockAnnotator
  configure: (options) ->
    {@store, @plugins} = options

class MockStoreSimple
class MockStore
  constructor: (@foo, @bar) ->
  configure: (options) ->
    {@core} = options

class MockPluginA
  constructor: (@one, @two) ->
  configure: (options) ->
    {@core} = options
class MockPluginB

describe 'Factory', ->
  it 'should return an instance of the core class from getInstance', ->
    f = new Factory(MockAnnotator)
    a = f.getInstance()
    assert.instanceOf(a, MockAnnotator)

  it 'should return a new instance of the core class with every call to getInstance', ->
    f = new Factory(MockAnnotator)
    a = f.getInstance()
    b = f.getInstance()
    assert.notEqual(a, b)

  it "should pass a new store instance to the core's `configure` method as `store`", ->
    f = new Factory(MockAnnotator)
    f.setStore(MockStore)
    a = f.getInstance()
    assert.instanceOf(a.store, MockStore)

  it 'should not call `configure` on core instances if they do not have the method', ->
    f = new Factory(MockAnnotatorSimple)
    f.setStore(MockStore)
    a = f.getInstance()
    # This would raise if the condition were not satisfied

  it "should pass different store instances to each core instance", ->
    f = new Factory(MockAnnotator)
    f.setStore(MockStore)
    a = f.getInstance()
    b = f.getInstance()
    assert.notEqual(a.store, b.store)

  it 'should call `configure` with the `store` property set to null when store ctor is not set', ->
    f = new Factory(MockAnnotator)
    a = f.getInstance()
    assert.isNull(a.store)

  it 'should call `configure` on store instances with the core instance as `core`', ->
    f = new Factory(MockAnnotator)
    f.setStore(MockStore)
    a = f.getInstance()
    assert.equal(a.store.core, a)

  it 'should not call `configure` on store instances if they do not have the method', ->
    f = new Factory(MockAnnotator)
    f.setStore(MockStoreSimple)
    a = f.getInstance()
    # This would raise if the condition were not satisfied

  it "should pass arguments to store instances", ->
    f = new Factory(MockAnnotator)
    f.setStore(MockStore, 'woop', {animal: "giraffe"})
    a = f.getInstance()
    assert.equal('woop', a.store.foo)
    assert.deepEqual({animal: "giraffe"}, a.store.bar)

  it "should create instances of added plugins and pass them to the core's `configure` method as `plugins`", ->
    f = new Factory(MockAnnotator)
    f.addPlugin(MockPluginA)
    f.addPlugin(MockPluginB)
    a = f.getInstance()
    assert.instanceOf(a.plugins[0], MockPluginA)
    assert.instanceOf(a.plugins[1], MockPluginB)

  it "should create different instances of added plugins for different core instances", ->
    f = new Factory(MockAnnotator)
    f.addPlugin(MockPluginA)
    a = f.getInstance()
    b = f.getInstance()
    assert.notEqual(a.plugins[0], b.plugins[0])

  it 'should call `configure` on plugin instances with the core instance as `core`', ->
    f = new Factory(MockAnnotator)
    f.addPlugin(MockPluginA)
    a = f.getInstance()
    assert.equal(a.plugins[0].core, a)

  it 'should not call `configure` on plugin instances if they do not have the method', ->
    f = new Factory(MockAnnotator)
    f.addPlugin(MockPluginB)
    a = f.getInstance()
    # This would raise if the condition were not satisfied

  it "should pass arguments to plugin instances", ->
    f = new Factory(MockAnnotator)
    f.addPlugin(MockPluginA, 'one', 2)
    f.addPlugin(MockPluginA, 1, 'two')
    a = f.getInstance()
    assert.equal('one', a.plugins[0].one)
    assert.equal(2, a.plugins[0].two)
    assert.equal(1, a.plugins[1].one)
    assert.equal('two', a.plugins[1].two)
