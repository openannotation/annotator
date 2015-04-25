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
        it('should call module configure functions with the registry', function () {
            var b = new app.App();
            var config = sandbox.stub();
            var mod = function () {
                return {configure: config};
            };
            b.include(mod);
            sinon.assert.calledWith(config, b.registry);
        });

        it('should call module functions with options if supplied', function () {
            var b = new app.App();
            var mod = sandbox.stub().returns({});
            b.include(mod, {foo: 'bar'});
            sinon.assert.calledWith(mod, {foo: 'bar'});
        });
    });

    describe('#destroy', function () {
        it("should call each module's destroy function, if it has one", function (done) {
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
        it('should run the named hook handler on each module', function () {
            var b = new app.App();
            var hook1 = sandbox.stub();
            var hook2 = sandbox.stub();
            var mod1 = function () { return {annotationCreated: hook1}; };
            var mod2 = function () { return {annotationCreated: hook2}; };
            var mod3 = function () { return {}; };
            b.include(mod1);
            b.include(mod2);
            b.include(mod3);

            b.runHook('annotationCreated');

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

            plug1.annotationCreated = sandbox.stub().returns(123);
            plug2.annotationCreated = sandbox.stub().returns(Promise.resolve("ok"));

            var delayedResolve = null;
            plug3.annotationCreated = sandbox.stub().returns(new Promise(function (resolve) {
                delayedResolve = resolve;
            }));

            var ret = b.runHook('annotationCreated');
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
            plug1.annotationCreated = sandbox.stub().returns(Promise.resolve("ok"));

            var delayedReject = null;
            plug2.annotationCreated = sandbox.stub().returns(new Promise(function (resolve, reject) {
                delayedReject = reject;
            }));

            var ret = b.runHook('annotationCreated');
            ret.then(function () {
                done(new Error("Promise should not have been resolved!"));
            }, function () {
                done();
            });

            delayedReject("fail...");
        });
    });

    describe('#start', function () {
        it('sets the authz property on the app', function () {
            var b = new app.App();
            b.start();

            assert.ok(b.authz);
        });

        it('sets the ident property on the app', function () {
            var b = new app.App();
            b.start();

            assert.ok(b.ident);
        });

        it('sets the notify property on the app', function () {
            var b = new app.App();
            b.start();

            assert.ok(b.notify);
        });

        it('sets the annotations property on app to be a storage adapter', function () {
            var b = new app.App();
            var s = sandbox.stub();
            var adapter = {};
            sandbox.stub(storage, 'StorageAdapter').returns(adapter);
            b.registry.registerUtility(s, 'storage');

            b.start();

            assert.equal(adapter, b.annotations);
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

        it("should run the module 'start' hook", function () {
            var b = new app.App();
            var start = sandbox.stub();
            var mod = function () { return {start: start}; };

            b.include(mod);
            b.start();

            sinon.assert.calledWith(start, b);
        });
    });
});
