h = require('helpers')
Annotator = require('../../src/annotator')
Plugin = require('../../src/plugin')
$ = require('../../src/util').$


class PluginExample extends Plugin
  events:
    'wibble': 'push'

  push: ->


describe 'Plugin', ->
  annotator = null
  callback = sinon.stub()
  plugin = null
  fix = null

  beforeEach ->
    fix = h.fix()
    plugin = new PluginExample(fix)
    plugin.annotator = annotator = {}

    BackboneEvents = require('backbone-events-standalone')
    BackboneEvents.mixin(annotator)

    sinon.spy(PluginExample::, 'push')
    plugin.pluginInit()

    $('body').bind('custom', callback)

  afterEach ->
    PluginExample::push.restore()
    plugin.destroy()

    $('body').unbind('custom', callback)

  it "will bind custom events to annotator if no selector is specified", ->
    annotator.trigger('wibble')
    assert(plugin.push.calledOnce)

  it "should not bubble custom events", ->
    plugin.publish('custom')
    assert.isFalse(callback.called)
