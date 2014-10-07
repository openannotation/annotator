var $, FailingMockStorage, MockHookRunner, MockStorage, Promise, Storage, keyAbsent, _ref;

Storage = require('../../../src/storage');

_ref = require('../../../src/util'), $ = _ref.$, Promise = _ref.Promise;

MockHookRunner = function() {
    this.calls = [];
    this.runHook = (function(_this) {
        return function(name, args) {
            _this.calls.push({
                name: name,
                args: args
            });
            return Promise.resolve();
        };
    })(this);
    return this;
};

MockStorage = function() {};

MockStorage.prototype.create = function(annotation) {
    annotation.stored = true;
    this._record('create');
    return annotation;
};

MockStorage.prototype.update = function(annotation) {
    annotation.stored = true;
    this._record('update');
    return annotation;
};

MockStorage.prototype["delete"] = function(annotation) {
    annotation.stored = true;
    this._record('delete');
    return annotation;
};

MockStorage.prototype.query = function(queryObj) {
    this._record('query');
    return [
        [], {
            total: 0
        }
    ];
};

MockStorage.prototype._record = function(name) {
    if (typeof this._callRecorder === 'function') {
        return this._callRecorder(name);
    }
};

FailingMockStorage = function() {};

FailingMockStorage.prototype.create = function(annotation) {
    return Promise.reject("failure message");
};

FailingMockStorage.prototype.update = function(annotation) {
    return Promise.reject("failure message");
};

FailingMockStorage.prototype["delete"] = function(annotation) {
    return Promise.reject("failure message");
};

FailingMockStorage.prototype.query = function(queryObj) {
    return Promise.reject("failure message");
};

keyAbsent = function(key) {
    return sinon.match(function(val) {
        return !(key in val);
    }, "" + key + " was found in object");
};

describe('Storage.StorageAdapter', function() {
    var a, assertDataReceived, assertPromiseRejected, assertPromiseResolved, noop, s, sandbox;
    noop = function() {
        return Promise.resolve();
    };
    a = null;
    s = null;
    sandbox = null;
    beforeEach(function() {
        sandbox = sinon.sandbox.create();
        s = new MockStorage();
        a = new Storage.StorageAdapter(s, noop);
        sandbox.spy(s, 'create');
        sandbox.spy(s, 'update');
        sandbox.spy(s, 'delete');
        return sandbox.spy(s, 'query');
    });
    afterEach(function() {
        return sandbox.restore();
    });
    // Helper function for testing that the correct data is received by the
    // store method of the specified name
    assertDataReceived = function(method, passed, expected, done) {
        return a[method](passed).then(function() {
            sinon.assert.calledOnce(s[method]);
            return sinon.assert.calledWith(s[method], expected);
        }).then(done, done);
    };
    // Helper function for testing that the return value from the adapter is
    // a correctly resolved promise
    assertPromiseResolved = function(method, passed, expected, done) {
        return a[method](passed).then(function(ret) {
            // The returned object should be the SAME object as originally passed
            // in
            assert.strictEqual(ret, passed);
            // But its contents may have changed
            return assert.deepEqual(ret, expected);
        }).then(done, done);
    };
    // Helper function for testing that the return value from the adapter is
    // a correctly rejected promise
    assertPromiseRejected = function(method, passed, expected, done) {
        s = new FailingMockStorage();
        a = new Storage.StorageAdapter(s, noop);
        return a[method](passed).then(function() {
            return done(new Error("Promise should not have been resolved!"));
        }, function(ret) {
            return assert.deepEqual(ret, expected);
        }).then(done, done);
    };
    describe('#create()', function() {
        it("should pass annotation data to the store's #create()", function(done) {
            return assertDataReceived('create', {
                some: 'data'
            }, sinon.match({
                some: 'data'
            }), done);
        });
        it("should return a promise resolving to the created annotation", function(done) {
            return assertPromiseResolved('create', {
                some: 'data'
            }, {
                some: 'data',
                stored: true
            }, done);
        });
        it("should return a promise that rejects if the store rejects", function(done) {
            return assertPromiseRejected('create', {
                some: 'data'
            }, "failure message", done);
        });
        it("should strip _local data before passing to the store", function(done) {
            return assertDataReceived('create', {
                some: 'data',
                _local: 'nottobepassedon'
            }, keyAbsent('_local'), done);
        });
        return it("should run the onBeforeAnnotationCreated/onAnnotationCreated hooks " + "before/after calling the store", function(done) {
            var ann, hr;
            hr = MockHookRunner();
            s = new MockStorage();
            s._callRecorder = hr.runHook;
            a = new Storage.StorageAdapter(s, hr.runHook);
            ann = {
                some: 'data'
            };
            return a.create(ann).then(function() {
                assert.deepEqual(hr.calls[0].name, 'onBeforeAnnotationCreated');
                assert.strictEqual(hr.calls[0].args[0], ann);
                assert.deepEqual(hr.calls[1].name, 'create');
                assert.deepEqual(hr.calls[2].name, 'onAnnotationCreated');
                return assert.strictEqual(hr.calls[2].args[0], ann);
            }).then(done, done);
        });
    });
    describe('#update()', function() {
        it("should pass annotation data to the store's #update()", function(done) {
            return assertDataReceived('update', {
                id: '123',
                some: 'data'
            }, sinon.match({
                id: '123',
                some: 'data'
            }), done);
        });
        it("should return a promise resolving to the updated annotation", function(done) {
            return assertPromiseResolved('update', {
                id: '123',
                some: 'data'
            }, {
                id: '123',
                some: 'data',
                stored: true
            }, done);
        });
        it("should return a promise that rejects if the store rejects", function(done) {
            return assertPromiseRejected('update', {
                id: '123',
                some: 'data'
            }, "failure message", done);
        });
        it("should strip _local data before passing to the store", function(done) {
            return assertDataReceived('update', {
                id: '123',
                some: 'data',
                _local: 'nottobepassedon'
            }, keyAbsent('_local'), done);
        });
        it("should throw a TypeError if the data lacks an id", function() {
            var ann;
            ann = {
                some: 'data'
            };
            return assert.throws((function() {
                return a.update(ann);
            }), TypeError, ' id ');
        });
        return it("should run the onBeforeAnnotationUpdated/onAnnotationUpdated hooks " + "before/after calling the store", function(done) {
            var ann, hr;
            hr = MockHookRunner();
            s = new MockStorage();
            s._callRecorder = hr.runHook;
            a = new Storage.StorageAdapter(s, hr.runHook);
            ann = {
                id: '123',
                some: 'data'
            };
            return a.update(ann).then(function() {
                assert.deepEqual(hr.calls[0].name, 'onBeforeAnnotationUpdated');
                assert.strictEqual(hr.calls[0].args[0], ann);
                assert.deepEqual(hr.calls[1].name, 'update');
                assert.deepEqual(hr.calls[2].name, 'onAnnotationUpdated');
                return assert.strictEqual(hr.calls[2].args[0], ann);
            }).then(done, done);
        });
    });
    describe('#delete()', function() {
        it("should pass annotation data to the store's #delete()", function(done) {
            return assertDataReceived('delete', {
                id: '123',
                some: 'data'
            }, sinon.match({
                id: '123',
                some: 'data'
            }), done);
        });
        it("should return a promise resolving to the deleted annotation", function(done) {
            return assertPromiseResolved('delete', {
                id: '123',
                some: 'data'
            }, {
                id: '123',
                some: 'data',
                stored: true
            }, done);
        });
        it("should return a promise that rejects if the store rejects", function(done) {
            return assertPromiseRejected('delete', {
                id: '123',
                some: 'data'
            }, "failure message", done);
        });
        it("should strip _local data before passing to the store", function(done) {
            return assertDataReceived('delete', {
                id: '123',
                some: 'data',
                _local: 'nottobepassedon'
            }, keyAbsent('_local'), done);
        });
        it("should throw a TypeError if the data lacks an id", function() {
            var ann;
            ann = {
                some: 'data'
            };
            return assert.throws((function() {
                return a["delete"](ann);
            }), TypeError, ' id ');
        });
        return it("should run the onBeforeAnnotationDeleted/onAnnotationDeleted hooks " + "before/after calling the store", function(done) {
            var ann, hr;
            hr = MockHookRunner();
            s = new MockStorage();
            s._callRecorder = hr.runHook;
            a = new Storage.StorageAdapter(s, hr.runHook);
            ann = {
                id: '123',
                some: 'data'
            };
            return a["delete"](ann).then(function() {
                assert.deepEqual(hr.calls[0].name, 'onBeforeAnnotationDeleted');
                assert.strictEqual(hr.calls[0].args[0], ann);
                assert.deepEqual(hr.calls[1].name, 'delete');
                assert.deepEqual(hr.calls[2].name, 'onAnnotationDeleted');
                return assert.strictEqual(hr.calls[2].args[0], ann);
            }).then(done, done);
        });
    });
    describe('#query()', function() {
        it("should invoke the query method on the registered store service", function() {
            var query;
            query = {
                url: 'foo'
            };
            a.query(query);
            return sinon.assert.calledWith(s.query, query);
        });
        it("should return a promise resolving to the query result", function(done) {
            var query;
            query = {
                url: 'foo'
            };
            return a.query(query).then(function(ret) {
                return assert.deepEqual(ret, [
                    [], {
                        total: 0
                    }
                ]);
            }).then(done, done);
        });
        return it("should return a promise that rejects if the store rejects", function(done) {
            var query, res;
            s = new FailingMockStorage();
            a = new Storage.StorageAdapter(s, noop);
            query = {
                url: 'foo'
            };
            res = a.query(query);
            return res.then(function() {
                return done(new Error("Promise should not have been resolved!"));
            }, function(ret) {
                return assert.deepEqual(ret, "failure message");
            }).then(done, done);
        });
    });
    return describe('#load()', function() {
        it("should invoke the query method on the registered store service", function() {
            var query;
            query = {
                url: 'foo'
            };
            a.load(query);
            return sinon.assert.calledWith(s.query, query);
        });
        return it("should run the onAnnotationsLoaded hook after calling " + "the store", function(done) {
            var hr, query;
            hr = MockHookRunner();
            s = new MockStorage();
            s._callRecorder = hr.runHook;
            a = new Storage.StorageAdapter(s, hr.runHook);
            query = {
                url: 'foo'
            };
            return a.load(query).then(function() {
                assert.deepEqual(hr.calls[0].name, 'query');
                assert.deepEqual(hr.calls[1].name, 'onAnnotationsLoaded');
                return assert.deepEqual(hr.calls[1].args, [
                    [
                        [], {
                            total: 0
                        }
                    ]
                ]);
            }).then(done, done);
        });
    });
});
