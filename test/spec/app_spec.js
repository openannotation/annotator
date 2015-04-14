var assert = require('assertive-chai').assert;

var Promise = require('es6-promise').Promise;

var app = require('../../src/app');
var storage = require('../../src/storage');


describe('App', function () {
    var sandbox;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
    });

    afterEach(function () {
        sandbox.restore();
    });

    describe('#include', function () {
        it('should call plugin configure functions with the registry', function () {
            var b = new app.App();
            var config = sandbox.stub();
            var mod = function () {
                return {configure: config};
            };
            b.include(mod);
            sinon.assert.calledWith(config, b.registry);
        });

        it('should call plugin module functions with options if supplied', function () {
            var b = new app.App();
            var mod = sandbox.stub().returns({});
            b.include(mod, {foo: 'bar'});
            sinon.assert.calledWith(mod, {foo: 'bar'});
        });
    });

    describe('#destroy', function () {
        it("should call each plugin's destroy function, if it has one", function (done) {
            var b = new app.App();
            var destroy1 = sandbox.stub();
            var destroy2 = sandbox.stub();
            var mod1 = function () { return {destroy: destroy1}; };
            var mod2 = function () { return {destroy: destroy2}; };
            var mod3 = function () { return {}; };
            b.include(mod1);
            b.include(mod2);
            b.include(mod3);
            b.destroy()
                .then(function () {
                    sinon.assert.called(destroy1);
                    sinon.assert.called(destroy2);
                })
                .then(done, done);
        });
    });

    describe('#runHook', function () {
        it('should run the named hook handler on each plugin', function () {
            var b = new app.App();
            var hook1 = sandbox.stub();
            var hook2 = sandbox.stub();
            var mod1 = function () { return {onAnnotationCreated: hook1}; };
            var mod2 = function () { return {onAnnotationCreated: hook2}; };
            var mod3 = function () { return {}; };
            b.include(mod1);
            b.include(mod2);
            b.include(mod3);

            b.runHook('onAnnotationCreated');

            sinon.assert.calledWithExactly(hook1);
            sinon.assert.calledWithExactly(hook2);
        });

        it('should return a promise that resolves if all the ' + 'handlers resolve', function (done) {
            var b = new app.App();
            var plug1 = {};
            var plug2 = {};
            var plug3 = {};
            var mod1 = function () { return plug1; };
            var mod2 = function () { return plug2; };
            var mod3 = function () { return plug3; };
            b.include(mod1);
            b.include(mod2);
            b.include(mod3);

            plug1.onAnnotationCreated = sandbox.stub().returns(123);
            plug2.onAnnotationCreated = sandbox.stub().returns(Promise.resolve("ok"));

            var delayedResolve = null;
            plug3.onAnnotationCreated = sandbox.stub().returns(new Promise(function (resolve) {
                delayedResolve = resolve;
            }));

            var ret = b.runHook('onAnnotationCreated');
            ret.then(function () {
                done();
            }, function () {
                done(new Error("Promise should not have been rejected!"));
            });

            delayedResolve("finally...");
        });

        it('should return a promise that rejects if any handler rejects', function (done) {
            var b = new app.App();
            var plug1 = {};
            var plug2 = {};
            var mod1 = function () { return plug1; };
            var mod2 = function () { return plug2; };
            b.include(mod1);
            b.include(mod2);
            plug1.onAnnotationCreated = sandbox.stub().returns(Promise.resolve("ok"));

            var delayedReject = null;
            plug2.onAnnotationCreated = sandbox.stub().returns(new Promise(function (resolve, reject) {
                delayedReject = reject;
            }));

            var ret = b.runHook('onAnnotationCreated');
            ret.then(function () {
                done(new Error("Promise should not have been resolved!"));
            }, function () {
                done();
            });

            delayedReject("fail...");
        });
    });

    describe('#start', function () {
        it('sets the authz property on the app and registry', function () {
            var b = new app.App();
            b.start();

            assert.ok(b.authz);
            assert.ok(b.registry.authz);
        });

        it('sets the ident property on the app and registry', function () {
            var b = new app.App();
            b.start();

            assert.ok(b.ident);
            assert.ok(b.registry.ident);
        });

        it('sets the notify property on the app and registry', function () {
            var b = new app.App();
            b.start();

            assert.ok(b.notify);
            assert.ok(b.registry.notify);
        });

        it('sets the annotations property on app and registry to be a storage adapter', function () {
            var b = new app.App();
            var s = sandbox.stub();
            var adapter = {};
            sandbox.stub(storage, 'StorageAdapter').returns(adapter);
            b.registry.registerUtility(s, 'storage');

            b.start();

            assert.equal(adapter, b.registry.annotations);
        });

        it('should pass the adapter the storage component', function () {
            var b = new app.App();
            var s = sandbox.stub();
            sandbox.stub(storage, 'StorageAdapter').returns('adapter');
            b.registry.registerUtility(s, 'storage');

            b.start();

            sinon.assert.calledOnce(storage.StorageAdapter);
            sinon.assert.calledWith(storage.StorageAdapter, s);
        });

        it('should pass the adapter a hook runner which calls the runHook method of the app', function () {
            var b = new app.App();
            var s = sandbox.stub().returns('storage');
            sandbox.stub(b, 'runHook');
            sandbox.stub(storage, 'StorageAdapter').returns('adapter');
            b.registry.registerUtility(s, 'storage');

            b.start();

            var hookRunner = storage.StorageAdapter.firstCall.args[1];
            hookRunner('foo', [1, 2, 3]);

            sinon.assert.calledWith(b.runHook, 'foo', [1, 2, 3]);
        });
    });
});


describe("supported()", function () {
    var scope = null;

    beforeEach(function () {
        scope = {
            getSelection: function () {},
            JSON: window.JSON
        };
    });

    it("returns true if all is well", function () {
        assert.isTrue(app.supported(null, scope));
    });

    it("returns false if scope has no getSelection function", function () {
        delete scope.getSelection;
        assert.isFalse(app.supported(null, scope));
    });

    it("returns false if scope has no JSON object", function () {
        delete scope.JSON;
        assert.isFalse(app.supported(null, scope));
    });

    it("returns false if scope JSON object has no stringify function", function () {
        scope.JSON = {
            parse: function () {}
        };
        assert.isFalse(app.supported(null, scope));
    });

    it("returns false if scope JSON object has no parse function", function () {
        scope.JSON = {
            stringify: function () {}
        };
        assert.isFalse(app.supported(null, scope));
    });

    it("returns extra details if details is true and all is well", function () {
        var res;
        res = app.supported(true, scope);
        assert.isTrue(res.supported);
        assert.deepEqual(res.errors, []);
    });

    it("returns extra details if details is true and everything is broken", function () {
        var res;
        res = app.supported(true, {});
        assert.isFalse(res.supported);
        assert.equal(res.errors.length, 2);
    });
});
