var assert = require('assertive-chai').assert;

var Promise = require('../../src/util').Promise;

var core = require('../../src/core');

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
    this.hookCalls.push(['onAnnotationCreated', arguments]);
    return this.hookResult;
};

function MockPlugin(reg) {
    return new PluginHelper(reg);
}

function MockEmptyPlugin() {
    return {};
}

function StorageHelper(reg) {
    this.registry = reg;
    MockStorage.lastInstance = this;
}

function MockStorage(reg) {
    return new StorageHelper(reg);
}

function MockStorageAdapter(storage, hookRunner) {
    this.storage = storage;
    this.hookRunner = hookRunner;
    MockStorageAdapter.lastInstance = this;
}

describe('Annotator', function () {
    describe('#addPlugin', function () {
        it('should call plugin functions with a registry', function () {
            var b = new core.Annotator();
            b.addPlugin(MockPlugin);
            assert.strictEqual(MockPlugin.lastInstance.registry, b.registry);
        });

        it('should add the plugin object to its internal list of plugins', function () {
            var b = new core.Annotator();
            b.addPlugin(MockPlugin);
            assert.deepEqual(b.plugins, [MockPlugin.lastInstance]);
        });
    });

    describe('#destroy', function () {
        it("should call each plugin's onDestroy function, if it has one", function (done) {
            var b = new core.Annotator();
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
            var b = new core.Annotator();
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
            var b = new core.Annotator();
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
            var b = new core.Annotator();
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

    describe('#setAuthorizer', function () {
        it('should call authorizer functions with a registry', function () {
            var b = new core.Annotator();
            var spy = sinon.spy();
            b.setAuthorizer(spy);
            sinon.assert.calledWith(spy, b.registry);
        });

        it('should set registry `authorizer` to the return value of the authorizer function', function () {
            var b = new core.Annotator();
            var authorizer = {};
            b.setAuthorizer(function () { return authorizer; });
            assert.strictEqual(b.registry.authorizer, authorizer);
        });
    });

    describe('#setIdentifier', function () {
        it('should call identifier functions with a registry', function () {
            var b = new core.Annotator();
            var spy = sinon.spy();
            b.setIdentifier(spy);
            sinon.assert.calledWith(spy, b.registry);
        });

        it('should set registry `identifier` to the return value of the identifier function', function () {
            var b = new core.Annotator();
            var identifier = {};
            b.setIdentifier(function () { return identifier; });
            assert.strictEqual(b.registry.identifier, identifier);
        });
    });

    describe('#setNotifier', function () {
        it('should call notifier functions with a registry', function () {
            var b = new core.Annotator();
            var spy = sinon.spy();
            b.setNotifier(spy);
            sinon.assert.calledWith(spy, b.registry);
        });

        it('should set registry `notifier` to the return value of the notifier function', function () {
            var b = new core.Annotator();
            var notifier = {};
            b.setNotifier(function () { return notifier; });
            assert.strictEqual(b.registry.notifier, notifier);
        });
    });

    describe('#setStorage', function () {
        it('should call the storage function with a registry', function () {
            var b = new core.Annotator();
            b._storageAdapterType = MockStorageAdapter;
            b.setStorage(MockStorage);
            assert.strictEqual(MockStorage.lastInstance.registry, b.registry);
        });

        it('should set registry `annotations` to be a storage adapter', function () {
            var b = new core.Annotator();
            b._storageAdapterType = MockStorageAdapter;
            b.setStorage(MockStorage);

            assert.strictEqual(MockStorageAdapter.lastInstance, b.registry.annotations);
        });

        it('should pass the adapter the return value of the storage function', function () {
            var b = new core.Annotator();
            b._storageAdapterType = MockStorageAdapter;
            b.setStorage(MockStorage);

            assert.strictEqual(MockStorageAdapter.lastInstance.storage, MockStorage.lastInstance);
        });

        it('should pass the adapter a hook runner which calls the runHook method of the annotator', function () {
            var b = new core.Annotator();
            b._storageAdapterType = MockStorageAdapter;
            sinon.spy(b, 'runHook');
            b.setStorage(MockStorage);

            MockStorageAdapter.lastInstance.hookRunner('foo', [1, 2, 3]);
            sinon.assert.calledWith(b.runHook, 'foo', [1, 2, 3]);

            b.runHook.restore();
        });
    });
});
