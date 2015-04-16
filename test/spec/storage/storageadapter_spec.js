var assert = require('assertive-chai').assert;

var storage = require('../../../src/storage'),
    util = require('../../../src/util');

var Promise = util.Promise;


function MockHookRunner() {
    this.calls = [];
    this.runHook = (function (_this) {
        return function (name, args) {
            _this.calls.push({
                name: name,
                args: args
            });
            return Promise.resolve();
        };
    })(this);
    return this;
}


function MockStorage() {}

MockStorage.prototype.create = function (annotation) {
    annotation.stored = true;
    this._record('create');
    return annotation;
};

MockStorage.prototype.update = function (annotation) {
    annotation.stored = true;
    this._record('update');
    return annotation;
};

MockStorage.prototype["delete"] = function (annotation) {
    annotation.stored = true;
    this._record('delete');
    return annotation;
};

MockStorage.prototype.query = function () {
    this._record('query');
    return {results: [{id: 'foo'}], meta: {total: 1}};
};

MockStorage.prototype._record = function (name) {
    if (typeof this._callRecorder === 'function') {
        return this._callRecorder(name);
    }
};


function FailingMockStorage() {}

FailingMockStorage.prototype.create = function () {
    return Promise.reject("failure message");
};

FailingMockStorage.prototype.update = function () {
    return Promise.reject("failure message");
};

FailingMockStorage.prototype["delete"] = function () {
    return Promise.reject("failure message");
};

FailingMockStorage.prototype.query = function () {
    return Promise.reject("failure message");
};


function keyAbsent(key) {
    return sinon.match(function (val) {
        return !(key in val);
    }, String(key) + " was found in object");
}

describe('storage.StorageAdapter', function () {
    var noop = function () { return Promise.resolve(); },
        a = null,
        s = null,
        sandbox = null;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        s = new MockStorage();
        a = new storage.StorageAdapter(s, noop);
        sandbox.spy(s, 'create');
        sandbox.spy(s, 'update');
        sandbox.spy(s, 'delete');
        sandbox.spy(s, 'query');
    });

    afterEach(function () {
        sandbox.restore();
    });

    // Helper function for testing that the correct data is received by the
    // store method of the specified name
    function assertDataReceived(method, passed, expected, done) {
        a[method](passed)
            .then(function () {
                sinon.assert.calledOnce(s[method]);
                sinon.assert.calledWith(s[method], expected);
            })
            .then(done, done);
    }

    // Helper function for testing that the return value from the adapter is
    // a correctly resolved promise
    function assertPromiseResolved(method, passed, expected, done) {
        a[method](passed)
            .then(function (ret) {
                // The returned object should be the SAME object as originally
                // passed in
                assert.strictEqual(ret, passed);
                // But its contents may have changed
                assert.deepEqual(ret, expected);
            })
            .then(done, done);
    }

    // Helper function for testing that the return value from the adapter is
    // a correctly rejected promise
    function assertPromiseRejected(method, passed, expected, done) {
        s = new FailingMockStorage();
        a = new storage.StorageAdapter(s, noop);
        a[method](passed)
            .then(function () {
                done(new Error("Promise should not have been resolved!"));
            }, function (ret) {
                assert.deepEqual(ret, expected);
            })
            .then(done, done);
    }

    describe('#create()', function () {
        it("should pass annotation data to the store's #create()", function (done) {
            assertDataReceived(
                'create',
                {some: 'data'},
                sinon.match({some: 'data'}),
                done
            );
        });

        it("should return a promise resolving to the created annotation", function (done) {
            assertPromiseResolved(
                'create',
                {some: 'data'},
                {some: 'data', stored: true},
                done
            );
        });

        it("should return a promise that rejects if the store rejects", function (done) {
            assertPromiseRejected(
                'create',
                {some: 'data'},
                "failure message",
                done
            );
        });

        it("should strip _local data before passing to the store", function (done) {
            assertDataReceived(
                'create',
                {some: 'data', _local: 'nottobepassedon'},
                keyAbsent('_local'),
                done
            );
        });

        it("should run the beforeAnnotationCreated/annotationCreated hooks before/after calling the store", function (done) {
            var hr = MockHookRunner();
            s = new MockStorage();
            s._callRecorder = hr.runHook;
            a = new storage.StorageAdapter(s, hr.runHook);
            var ann = {
                some: 'data'
            };
            a.create(ann)
                .then(function () {
                    assert.deepEqual(hr.calls[0].name, 'beforeAnnotationCreated');
                    assert.strictEqual(hr.calls[0].args[0], ann);
                    assert.deepEqual(hr.calls[1].name, 'create');
                    assert.deepEqual(hr.calls[2].name, 'annotationCreated');
                    assert.strictEqual(hr.calls[2].args[0], ann);
                })
                .then(done, done);
        });
    });

    describe('#update()', function () {
        it("should pass annotation data to the store's #update()", function (done) {
            assertDataReceived(
                'update',
                {id: '123', some: 'data'},
                sinon.match({id: '123', some: 'data'}),
                done
            );
        });

        it("should return a promise resolving to the updated annotation", function (done) {
            assertPromiseResolved(
                'update',
                {id: '123', some: 'data'},
                {id: '123', some: 'data', stored: true},
                done
            );
        });

        it("should return a promise that rejects if the store rejects", function (done) {
            assertPromiseRejected(
                'update',
                {id: '123', some: 'data'},
                "failure message",
                done
            );
        });

        it("should strip _local data before passing to the store", function (done) {
            assertDataReceived(
                'update',
                {id: '123', some: 'data', _local: 'nottobepassedon'},
                keyAbsent('_local'),
                done
            );
        });

        it("should throw a TypeError if the data lacks an id", function () {
            var ann = {some: 'data'};
            assert.throws(function () {
                a.update(ann);
            }, TypeError, ' id ');
        });

        it("should run the beforeAnnotationUpdated/annotationUpdated hooks before/after calling the store", function (done) {
            var hr = MockHookRunner();
            s = new MockStorage();
            s._callRecorder = hr.runHook;
            a = new storage.StorageAdapter(s, hr.runHook);
            var ann = {
                id: '123',
                some: 'data'
            };
            a.update(ann)
                .then(function () {
                    assert.deepEqual(hr.calls[0].name, 'beforeAnnotationUpdated');
                    assert.strictEqual(hr.calls[0].args[0], ann);
                    assert.deepEqual(hr.calls[1].name, 'update');
                    assert.deepEqual(hr.calls[2].name, 'annotationUpdated');
                    assert.strictEqual(hr.calls[2].args[0], ann);
                })
                .then(done, done);
        });
    });

    describe('#delete()', function () {
        it("should pass annotation data to the store's #delete()", function (done) {
            assertDataReceived(
                'delete',
                {id: '123', some: 'data'},
                sinon.match({id: '123', some: 'data'}),
                done
            );
        });

        it("should return a promise resolving to the deleted annotation", function (done) {
            assertPromiseResolved(
                'delete',
                {id: '123', some: 'data'},
                {id: '123', some: 'data', stored: true},
                done
            );
        });

        it("should return a promise that rejects if the store rejects", function (done) {
            assertPromiseRejected(
                'delete',
                {id: '123', some: 'data'},
                "failure message",
                done
            );
        });

        it("should strip _local data before passing to the store", function (done) {
            assertDataReceived(
                'delete',
                {id: '123', some: 'data', _local: 'nottobepassedon'},
                keyAbsent('_local'),
                done
            );
        });

        it("should throw a TypeError if the data lacks an id", function () {
            var ann = {some: 'data'};

            assert.throws(function () {
                a["delete"](ann);
            }, TypeError, ' id ');
        });

        it("should run the beforeAnnotationDeleted/annotationDeleted hooks before/after calling the store", function (done) {
            var hr = MockHookRunner();
            s = new MockStorage();
            s._callRecorder = hr.runHook;
            a = new storage.StorageAdapter(s, hr.runHook);
            var ann = {
                id: '123',
                some: 'data'
            };
            a["delete"](ann)
                .then(function () {
                    assert.deepEqual(hr.calls[0].name, 'beforeAnnotationDeleted');
                    assert.strictEqual(hr.calls[0].args[0], ann);
                    assert.deepEqual(hr.calls[1].name, 'delete');
                    assert.deepEqual(hr.calls[2].name, 'annotationDeleted');
                    return assert.strictEqual(hr.calls[2].args[0], ann);
                })
                .then(done, done);
        });
    });

    describe('#query()', function () {
        it("should invoke the query method on the registered store service", function () {
            var query = {
                url: 'foo'
            };
            a.query(query);
            sinon.assert.calledWith(s.query, query);
        });

        it("should return a promise resolving to the query result", function (done) {
            var query = {
                url: 'foo'
            };
            a.query(query)
                .then(function (ret) {
                    assert.deepEqual(ret, {results: [{id: 'foo'}], meta: {total: 1}});
                })
                .then(done, done);
        });

        it("should return a promise that rejects if the store rejects", function (done) {
            s = new FailingMockStorage();
            a = new storage.StorageAdapter(s, noop);
            var query = {
                url: 'foo'
            };
            var res = a.query(query);
            res
                .then(function () {
                    done(new Error("Promise should not have been resolved!"));
                }, function (ret) {
                    assert.deepEqual(ret, "failure message");
                })
                .then(done, done);
        });
    });

    describe('#load()', function () {
        it("should invoke the query method on the registered store service", function () {
            var query = {
                url: 'foo'
            };
            a.load(query);
            sinon.assert.calledWith(s.query, query);
        });

        it("should run the annotationsLoaded hook after calling the store", function (done) {
            var hr = MockHookRunner();
            s = new MockStorage();
            s._callRecorder = hr.runHook;
            a = new storage.StorageAdapter(s, hr.runHook);
            var query = {
                url: 'foo'
            };
            a.load(query)
                .then(function () {
                    assert.deepEqual(hr.calls[0].name, 'query');
                    assert.deepEqual(hr.calls[1].name, 'annotationsLoaded');
                    assert.deepEqual(hr.calls[1].args, [[{id: 'foo'}]]);
                })
                .then(done, done);
        });
    });
});
