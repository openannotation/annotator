Storage = require('../../../src/storage')
$ = require('../../../src/util').$

describe "Storage.HTTPStorage", ->
  store = null
  server = null

  beforeEach ->
    store = Storage.HTTPStorage()
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

  it "update URL should be /store/annotations/{id} by default", ->
    store.update({text: "Donkeys on giraffes", id: 123})
    [url, _] = $.ajax.args[0]
    assert.equal("/store/annotations/123", url)

  it "delete URL should be /store/annotations/{id} by default", ->
    store.delete({text: "Donkeys on giraffes", id: 123})
    [url, _] = $.ajax.args[0]
    assert.equal("/store/annotations/123", url)

  it "should request custom URLs as specified by its options", ->
    store.options.prefix = '/some/prefix'
    store.options.urls.create = '/createMe'
    store.options.urls.update = '/{id}/updateMe'
    store.options.urls.destroy = '/{id}/destroyMe'

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
    store.options.urls.update = '/{id}/updateMe'
    store.options.urls.destroy = '/{id}/destroyMe'

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
    store.options.urls.update = '/update?foo&id={id}'
    store.options.urls.destroy = '/delete?id={id}&foo'

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

  it "should append _method to the form data if emulateHTTP and emulateJSON
      are both true", ->
    store.options.emulateHTTP = true
    store.options.emulateJSON = true
    store.delete({id: 123})
    [_, opts] = $.ajax.args[0]

    assert.deepEqual(opts.data, {
      _method: 'DELETE',
      json: '{"id":123}',
    })

  describe "error handling", ->
    xit "should be tested"
