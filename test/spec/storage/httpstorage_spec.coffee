var $, Storage;

Storage = require('../../../src/storage');

$ = require('../../../src/util').$;

describe("Storage.HTTPStorage", function() {
    var server, store;
    store = null;
    server = null;
    beforeEach(function() {
        store = Storage.HTTPStorage();
        return sinon.stub($, 'ajax').returns({});
    });
    afterEach(function() {
        return $.ajax.restore();
    });
    it("create should trigger a POST request", function() {
        var opts, _, _ref;
        store.create({
            text: "Donkeys on giraffes"
        });
        _ref = $.ajax.args[0], _ = _ref[0], opts = _ref[1];
        return assert.equal("POST", opts.type);
    });
    it("update should trigger a PUT request", function() {
        var opts, _, _ref;
        store.update({
            text: "Donkeys on giraffes",
            id: 123
        });
        _ref = $.ajax.args[0], _ = _ref[0], opts = _ref[1];
        return assert.equal("PUT", opts.type);
    });
    it("delete should trigger a DELETE request", function() {
        var opts, _, _ref;
        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        _ref = $.ajax.args[0], _ = _ref[0], opts = _ref[1];
        return assert.equal("DELETE", opts.type);
    });
    it("create URL should be /store/annotations by default", function() {
        var url, _, _ref;
        store.create({
            text: "Donkeys on giraffes"
        });
        _ref = $.ajax.args[0], url = _ref[0], _ = _ref[1];
        return assert.equal("/store/annotations", url);
    });
    it("update URL should be /store/annotations/{id} by default", function() {
        var url, _, _ref;
        store.update({
            text: "Donkeys on giraffes",
            id: 123
        });
        _ref = $.ajax.args[0], url = _ref[0], _ = _ref[1];
        return assert.equal("/store/annotations/123", url);
    });
    it("delete URL should be /store/annotations/{id} by default", function() {
        var url, _, _ref;
        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        _ref = $.ajax.args[0], url = _ref[0], _ = _ref[1];
        return assert.equal("/store/annotations/123", url);
    });
    it("should request custom URLs as specified by its options", function() {
        var url, _, _ref, _ref1, _ref2;
        store.options.prefix = '/some/prefix';
        store.options.urls.create = '/createMe';
        store.options.urls.update = '/{id}/updateMe';
        store.options.urls.destroy = '/{id}/destroyMe';
        store.create({
            text: "Donkeys on giraffes"
        });
        store.update({
            text: "Donkeys on giraffes",
            id: 123
        });
        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        _ref = $.ajax.args[0], url = _ref[0], _ = _ref[1];
        assert.equal('/some/prefix/createMe', url);
        _ref1 = $.ajax.args[1], url = _ref1[0], _ = _ref1[1];
        assert.equal('/some/prefix/123/updateMe', url);
        _ref2 = $.ajax.args[2], url = _ref2[0], _ = _ref2[1];
        return assert.equal('/some/prefix/123/destroyMe', url);
    });
    it("should generate URLs correctly with an empty prefix", function() {
        var url, _, _ref, _ref1, _ref2;
        store.options.prefix = '';
        store.options.urls.create = '/createMe';
        store.options.urls.update = '/{id}/updateMe';
        store.options.urls.destroy = '/{id}/destroyMe';
        store.create({
            text: "Donkeys on giraffes"
        });
        store.update({
            text: "Donkeys on giraffes",
            id: 123
        });
        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        _ref = $.ajax.args[0], url = _ref[0], _ = _ref[1];
        assert.equal('/createMe', url);
        _ref1 = $.ajax.args[1], url = _ref1[0], _ = _ref1[1];
        assert.equal('/123/updateMe', url);
        _ref2 = $.ajax.args[2], url = _ref2[0], _ = _ref2[1];
        return assert.equal('/123/destroyMe', url);
    });
    it("should generate URLs with substitution markers in query strings", function() {
        var url, _, _ref, _ref1;
        store.options.prefix = '/some/prefix';
        store.options.urls.update = '/update?foo&id={id}';
        store.options.urls.destroy = '/delete?id={id}&foo';
        store.update({
            text: "Donkeys on giraffes",
            id: 123
        });
        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        _ref = $.ajax.args[0], url = _ref[0], _ = _ref[1];
        assert.equal('/some/prefix/update?foo&id=123', url);
        _ref1 = $.ajax.args[1], url = _ref1[0], _ = _ref1[1];
        return assert.equal('/some/prefix/delete?id=123&foo', url);
    });
    it("should send custom headers added with setHeader", function() {
        var opts, _, _ref;
        store.setHeader('Fruit', 'Apple');
        store.setHeader('Colour', 'Green');
        store.create({
            text: "Donkeys on giraffes"
        });
        _ref = $.ajax.args[0], _ = _ref[0], opts = _ref[1];
        assert.equal('Apple', opts.headers['Fruit']);
        return assert.equal('Green', opts.headers['Colour']);
    });
    it("should emulate new-fangled HTTP if emulateHTTP is true", function() {
        var opts, _, _ref;
        store.options.emulateHTTP = true;
        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        _ref = $.ajax.args[0], _ = _ref[0], opts = _ref[1];
        assert.equal(opts.type, 'POST');
        return assert.deepEqual(opts.headers, {
            'X-HTTP-Method-Override': 'DELETE'
        });
    });
    it("should emulate proper JSON handling if emulateJSON is true", function() {
        var opts, _, _ref;
        store.options.emulateJSON = true;
        store["delete"]({
            id: 123
        });
        _ref = $.ajax.args[0], _ = _ref[0], opts = _ref[1];
        assert.deepEqual({
            json: '{"id":123}'
        }, opts.data);
        return assert.isUndefined(opts.contentType);
    });
    it("should append _method to the form data if emulateHTTP and emulateJSON are both true", function() {
        var opts, _, _ref;
        store.options.emulateHTTP = true;
        store.options.emulateJSON = true;
        store["delete"]({
            id: 123
        });
        _ref = $.ajax.args[0], _ = _ref[0], opts = _ref[1];
        return assert.deepEqual(opts.data, {
            _method: 'DELETE',
            json: '{"id":123}'
        });
    });
    return describe("error handling", function() {
        return xit("should be tested");
    });
});
