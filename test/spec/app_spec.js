var assert = require('assertive-chai').assert;

var Promise = require('es6-promise').Promise;

var app = require('../../src/app');
var storage = require('../../src/storage');

function PluginHelper(reg) {
    this.registry = reg;
    this.destroyed = false;
    this.hookCalls = [];
    this.hookResult = void 0;
    MockPlugin.lastInstance = this;
}

PluginHelper.prototype.onDestroy = function () {
    this.destroyed = true;
};

PluginHelper.prototype.onAnnotationCreated = function () {
    this.hookCalls.push(['onAnnotationCreated', [].slice.call(arguments)]);
    return this.hookResult;
};

function MockPlugin(reg) {
    return new PluginHelper(reg);
}

function MockEmptyPlugin() {
    return {};
}


describe('App', function () {
    var sandbox;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
    });

    afterEach(function () {
        sandbox.restore();
    });

    describe('#addPlugin', function () {
        it('should call plugin functions with a registry', function () {
            var b = new app.App();
            b.addPlugin(MockPlugin);
            assert.strictEqual(MockPlugin.lastInstance.registry, b.registry);
        });

        it('should add the plugin object to its internal list of plugins', function () {
            var b = new app.App();
            b.addPlugin(MockPlugin);
            assert.deepEqual(b.plugins, [MockPlugin.lastInstance]);
        });
    });

    describe('#destroy', function () {
        it("should call each plugin's onDestroy function, if it has one", function (done) {
            var b = new app.App();
            b.addPlugin(MockPlugin);
            b.addPlugin(MockPlugin);
            b.addPlugin(MockEmptyPlugin);
            b.destroy()
                .then(function () {
                    var result;
                    result = b.plugins.map(function (p) {
                        return p.destroyed;
                    });
                    assert.deepEqual([true, true, void 0], result);
                })
                .then(done, done);
        });
    });

    describe('#runHook', function () {
        it('should run the named hook handler on each plugin', function () {
            var b = new app.App();
            b.addPlugin(MockPlugin);
            var pluginOne = MockPlugin.lastInstance;
            b.addPlugin(MockPlugin);
            var pluginTwo = MockPlugin.lastInstance;
            b.addPlugin(MockPlugin);
            var pluginThree = MockPlugin.lastInstance;
            // Remove the hook handler on this plugin
            delete pluginThree.onAnnotationCreated;

            b.runHook('onAnnotationCreated');

            assert.deepEqual(pluginOne.hookCalls, [['onAnnotationCreated', []]]);
            assert.deepEqual(pluginTwo.hookCalls, [['onAnnotationCreated', []]]);
        });

        it('should return a promise that resolves if all the ' + 'handlers resolve', function (done) {
            var b = new app.App();
            b.addPlugin(MockPlugin);
            var pluginOne = MockPlugin.lastInstance;
            b.addPlugin(MockPlugin);
            var pluginTwo = MockPlugin.lastInstance;
            b.addPlugin(MockPlugin);
            var pluginThree = MockPlugin.lastInstance;

            pluginOne.hookResult = 123;
            pluginTwo.hookResult = Promise.resolve("ok");

            var delayedResolve = null;
            pluginThree.hookResult = new Promise(function (resolve) {
                delayedResolve = resolve;
            });

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
            b.addPlugin(MockPlugin);
            var pluginOne = MockPlugin.lastInstance;
            b.addPlugin(MockPlugin);
            var pluginTwo = MockPlugin.lastInstance;
            pluginOne.hookResult = Promise.resolve("ok");

            var delayedReject = null;
            pluginTwo.hookResult = new Promise(function (resolve, reject) {
                delayedReject = reject;
            });

            var ret = b.runHook('onAnnotationCreated');
            ret.then(function () {
                done(new Error("Promise should not have been resolved!"));
            }, function () {
                done();
            });

            delayedReject("fail...");
        });
    });

    describe('#finalize', function () {
        it('sets the authz property on the app and registry', function () {
            var b = new app.App();
            b.finalize();

            assert.ok(b.authz);
            assert.ok(b.registry.authz);
        });

        it('sets the ident property on the app and registry', function () {
            var b = new app.App();
            b.finalize();

            assert.ok(b.ident);
            assert.ok(b.registry.ident);
        });

        it('sets the notify property on the app and registry', function () {
            var b = new app.App();
            b.finalize();

            assert.ok(b.notify);
            assert.ok(b.registry.notify);
        });

        it('sets the annotations property on app and registry to be a storage adapter', function () {
            var b = new app.App();
            var s = sandbox.stub();
            var adapter = {};
            sandbox.stub(storage, 'StorageAdapter').returns(adapter);
            b.registry.registerUtility(s, 'storage');

            b.finalize();

            assert.equal(adapter, b.registry.annotations);
        });

        it('should pass the adapter the storage component', function () {
            var b = new app.App();
            var s = sandbox.stub();
            sandbox.stub(storage, 'StorageAdapter').returns('adapter');
            b.registry.registerUtility(s, 'storage');

            b.finalize();

            sinon.assert.calledOnce(storage.StorageAdapter);
            sinon.assert.calledWith(storage.StorageAdapter, s);
        });

        it('should pass the adapter a hook runner which calls the runHook method of the app', function () {
            var b = new app.App();
            var s = sandbox.stub().returns('storage');
            sandbox.stub(b, 'runHook');
            sandbox.stub(storage, 'StorageAdapter').returns('adapter');
            b.registry.registerUtility(s, 'storage');

            b.finalize();

            var hookRunner = storage.StorageAdapter.firstCall.args[1];
            hookRunner('foo', [1,2,3]);

            sinon.assert.calledWith(b.runHook, 'foo', [1,2,3]);
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
