Annotator = require('annotator')
$ = Annotator.Util.$
Store = require('../../../src/plugin/store')

describe "Annotator.Plugin.Store", ->
  store = null
  server = null

  beforeEach ->
    store = new Annotator.Plugin.Store()
    sinon.stub($, 'ajax').returns({})

  afterEach ->
    $.ajax.restore()

  it "create should trigger a POST request", ->
    store.create({text: "Donkeys on giraffes"})
    [_, opts] = $.ajax.args[0]
    assert.equal("POST", opts.type)

  it "update should trigger a PUT request", ->
    store.update({text: "Donkeys on giraffes", id: 123})
    [_, opts] = $.ajax.args[0]
    assert.equal("PUT", opts.type)

  it "delete should trigger a DELETE request", ->
    store.delete({text: "Donkeys on giraffes", id: 123})
    [_, opts] = $.ajax.args[0]
    assert.equal("DELETE", opts.type)

  it "create URL should be /store/annotations by default", ->
    store.create({text: "Donkeys on giraffes"})
    [url, _] = $.ajax.args[0]
    assert.equal("/store/annotations", url)

  it "update URL should be /store/annotations/:id by default", ->
    store.update({text: "Donkeys on giraffes", id: 123})
    [url, _] = $.ajax.args[0]
    assert.equal("/store/annotations/123", url)

  it "delete URL should be /store/annotations/:id by default", ->
    store.delete({text: "Donkeys on giraffes", id: 123})
    [url, _] = $.ajax.args[0]
    assert.equal("/store/annotations/123", url)

  it "should request custom URLs as specified by its options", ->
    store.options.prefix = '/some/prefix'
    store.options.urls.create = '/createMe'
    store.options.urls.update = '/:id/updateMe'
    store.options.urls.destroy = '/:id/destroyMe'

    store.create({text: "Donkeys on giraffes"})
    store.update({text: "Donkeys on giraffes", id: 123})
    store.delete({text: "Donkeys on giraffes", id: 123})

    [url, _] = $.ajax.args[0]
    assert.equal('/some/prefix/createMe', url)

    [url, _] = $.ajax.args[1]
    assert.equal('/some/prefix/123/updateMe', url)

    [url, _] = $.ajax.args[2]
    assert.equal('/some/prefix/123/destroyMe', url)

  it "should generate URLs correctly with an empty prefix", ->
    store.options.prefix = ''
    store.options.urls.create = '/createMe'
    store.options.urls.update = '/:id/updateMe'
    store.options.urls.destroy = '/:id/destroyMe'

    store.create({text: "Donkeys on giraffes"})
    store.update({text: "Donkeys on giraffes", id: 123})
    store.delete({text: "Donkeys on giraffes", id: 123})

    [url, _] = $.ajax.args[0]
    assert.equal('/createMe', url)

    [url, _] = $.ajax.args[1]
    assert.equal('/123/updateMe', url)

    [url, _] = $.ajax.args[2]
    assert.equal('/123/destroyMe', url)

  it "should generate URLs with substitution markers in query strings", ->
    store.options.prefix = '/some/prefix'
    store.options.urls.update = '/update?foo&id=:id'
    store.options.urls.destroy = '/delete?id=:id&foo'

    store.update({text: "Donkeys on giraffes", id: 123})
    store.delete({text: "Donkeys on giraffes", id: 123})

    [url, _] = $.ajax.args[0]
    assert.equal('/some/prefix/update?foo&id=123', url)

    [url, _] = $.ajax.args[1]
    assert.equal('/some/prefix/delete?id=123&foo', url)

  it "should send custom headers added with setHeader", ->
    store.setHeader('Fruit', 'Apple')
    store.setHeader('Colour', 'Green')
    store.create({text: "Donkeys on giraffes"})
    [_, opts] = $.ajax.args[0]
    assert.equal('Apple', opts.headers['Fruit'])
    assert.equal('Green', opts.headers['Colour'])

  it "should emulate new-fangled HTTP if emulateHTTP is true", ->
    store.options.emulateHTTP = true
    store.delete({text: "Donkeys on giraffes", id: 123})
    [_, opts] = $.ajax.args[0]

    assert.equal(opts.type, 'POST')
    assert.deepEqual(opts.headers, 'X-HTTP-Method-Override': 'DELETE')

  it "should emulate proper JSON handling if emulateJSON is true", ->
    store.options.emulateJSON = true
    store.delete({id: 123})
    [_, opts] = $.ajax.args[0]

    assert.deepEqual({json: '{"id":123}'}, opts.data)
    assert.isUndefined(opts.contentType)

  it "should append _method to the form data if emulateHTTP and emulateJSON are both true", ->
    store.options.emulateHTTP = true
    store.options.emulateJSON = true
    store.delete({id: 123})
    [_, opts] = $.ajax.args[0]

    assert.deepEqual(opts.data, {
      _method: 'DELETE',
      json: '{"id":123}',
    })

  describe "_onError", ->
    message = null
    requests = [
      {}
      {}
      {_action: 'read', _id: 'jim'}
      {_action: 'search'}
      {_action: 'read'}
      {status: 401, _action: 'delete', '_id': 'cake'}
      {status: 404, _action: 'delete', '_id': 'cake'}
      {status: 500, _action: 'delete', '_id': 'cake'}
    ]

    beforeEach ->
      sinon.stub(Annotator, 'showNotification')
      sinon.stub(console,   'error')

      store._onError requests.shift()
      message = Annotator.showNotification.lastCall.args[0]

    afterEach ->
      Annotator.showNotification.restore()
      console.error.restore()

    it "should call call Annotator.showNotification() with a message and error style", ->
      assert(Annotator.showNotification.calledOnce)
      assert.equal(Annotator.showNotification.lastCall.args[1], Annotator.Notification.ERROR)

    it "should call console.error with a message", ->
      assert(console.error.calledOnce)

    it "should give a default message if xhr.status id not provided", ->
      assert.equal(message, "Sorry we could not read this annotation")

    it "should give a default specific message if xhr._action is 'search'", ->
      assert.equal(message, "Sorry we could not search the store for annotations")

    it "should give a default specific message if xhr._action is 'read' and there is no xhr._id", ->
      assert.equal(message, "Sorry we could not read the annotations from the store")

    it "should give a specific message if xhr.status == 401", ->
      assert.equal(message, "Sorry you are not allowed to delete this annotation")

    it "should give a specific message if xhr.status == 404", ->
      assert.equal(message, "Sorry we could not connect to the annotations store")

    it "should give a specific message if xhr.status == 500", ->
      assert.equal(message, "Sorry something went wrong with the annotation store")
