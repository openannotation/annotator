var assert = require('assertive-chai').assert;

var storage = require('../../../src/storage');

describe("storage.HttpStorage", function () {
    var store, xhr, lastReq;

    beforeEach(function () {
        lastReq = null;
        store = new storage.HttpStorage();
        xhr = sinon.useFakeXMLHttpRequest();
        xhr.onCreate = function (r) {
            lastReq = r;
        };
    });

    afterEach(function () {
        xhr.restore();
    });

    it("create should trigger a POST request", function () {
        store.create({
            text: "Donkeys on giraffes"
        });
        assert.equal(lastReq.method, "POST");
    });

    it("update should trigger a PUT request", function () {
        store.update({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.method, "PUT");
    });

    it("delete should trigger a DELETE request", function () {
        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.method, "DELETE");
    });

    it("create URL should be /store/annotations by default", function () {
        store.create({
            text: "Donkeys on giraffes"
        });
        assert.equal(lastReq.url, "/store/annotations");
    });

    it("update URL should be /store/annotations/{id} by default", function () {
        store.update({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.url, "/store/annotations/123");
    });

    it("delete URL should be /store/annotations/{id} by default", function () {
        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.url, "/store/annotations/123");
    });

    it("should request custom URLs as specified by its options", function () {
        store.options.prefix = '/some/prefix';
        store.options.urls.create = '/createMe';
        store.options.urls.update = '/{id}/updateMe';
        store.options.urls.destroy = '/{id}/destroyMe';

        store.create({
            text: "Donkeys on giraffes"
        });
        assert.equal(lastReq.url, '/some/prefix/createMe');

        store.update({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.url, '/some/prefix/123/updateMe');

        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.url, '/some/prefix/123/destroyMe');
    });

    it("should generate URLs correctly with an empty prefix", function () {
        store.options.prefix = '';
        store.options.urls.create = '/createMe';
        store.options.urls.update = '/{id}/updateMe';
        store.options.urls.destroy = '/{id}/destroyMe';

        store.create({
            text: "Donkeys on giraffes"
        });
        assert.equal(lastReq.url, '/createMe');

        store.update({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.url, '/123/updateMe');

        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.url, '/123/destroyMe');
    });

    it("should generate URLs with substitution markers in query strings", function () {
        store.options.prefix = '/some/prefix';
        store.options.urls.update = '/update?foo&id={id}';
        store.options.urls.destroy = '/delete?id={id}&foo';

        store.update({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.url, '/some/prefix/update?foo&id=123');

        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.url, '/some/prefix/delete?id=123&foo');
    });

    it("should send custom headers added with setHeader", function () {
        store.setHeader('Fruit', 'Apple');
        store.setHeader('Colour', 'Green');
        store.create({
            text: "Donkeys on giraffes"
        });
        assert.equal(lastReq.requestHeaders.Fruit, 'Apple');
        assert.equal(lastReq.requestHeaders.Colour, 'Green');
    });

    it("should emulate new-fangled HTTP if emulateHTTP is true", function () {
        store.options.emulateHTTP = true;
        store["delete"]({
            text: "Donkeys on giraffes",
            id: 123
        });
        assert.equal(lastReq.method, 'POST');
        assert.equal(
            lastReq.requestHeaders['X-HTTP-Method-Override'],
            'DELETE'
        );
    });

    it("should emulate proper JSON handling if emulateJSON is true", function () {
        store.options.emulateJSON = true;
        store["delete"]({
            id: 123
        });
        assert.equal(
            lastReq.requestBody,
            'json=' + encodeURIComponent('{"id":123}')
        );
        assert.equal(
            lastReq.requestHeaders['Content-Type'],
            'application/x-www-form-urlencoded;charset=utf-8'
        );
    });

    it("should append _method to the form data if emulateHTTP and emulateJSON are both true", function () {
        store.options.emulateHTTP = true;
        store.options.emulateJSON = true;
        store["delete"]({
            id: 123
        });
        assert.include(lastReq.requestBody, '_method=DELETE');
    });

    describe("error handling", function () {
        var onError;

        beforeEach(function () {
            onError = sinon.spy();
        });

        it("calls the onError handler when an error occurs", function (done) {
            store = new storage.HttpStorage({
                onError: onError
            });
            var res = store.create({text: "Donkeys on giraffes"});

            lastReq.respond(400);

            var check = function () {
                sinon.assert.calledOnce(onError);
                done();
            };
            res.then(check, check);
        });
    });
});
