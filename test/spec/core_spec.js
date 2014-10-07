var MockEmptyPlugin, MockNotification, MockNotificationObj, MockPlugin, MockStorage, MockStorageAdapter, PluginHelper, Promise, StorageHelper, core;

Promise = require('../../src/util').Promise;

core = require('../../src/core');

PluginHelper = function(reg) {
    this.registry = reg;
    this.destroyed = false;
    this.hookCalls = [];
    this.hookResult = void 0;
    return MockPlugin.lastInstance = this;
};

PluginHelper.prototype.onDestroy = function() {
    return this.destroyed = true;
};

PluginHelper.prototype.onAnnotationCreated = function() {
    this.hookCalls.push(['onAnnotationCreated', arguments]);
    return this.hookResult;
};

MockPlugin = function(reg) {
    return new PluginHelper(reg);
};

MockEmptyPlugin = function() {
    return {};
};

StorageHelper = function() {
    return MockStorage.lastInstance = this;
};

MockNotificationObj = {};

MockNotification = function() {
    return MockNotificationObj;
};

MockStorage = function() {
    return new StorageHelper();
};

MockStorageAdapter = function(storage, hookRunner) {
    this.storage = storage;
    this.hookRunner = hookRunner;
    return MockStorageAdapter.lastInstance = this;
};

describe('AnnotatorCore', function() {
    describe('#addPlugin', function() {
        it('should call plugin functions with a registry', function() {
            var b;
            b = new core.AnnotatorCore();
            b.addPlugin(MockPlugin);
            return assert.strictEqual(MockPlugin.lastInstance.registry, b.registry);
        });
        return it('should add the plugin object to its internal list of plugins', function() {
            var b;
            b = new core.AnnotatorCore();
            b.addPlugin(MockPlugin);
            return assert.deepEqual(b.plugins, [MockPlugin.lastInstance]);
        });
    });
    describe('#destroy', function() {
        return it("should call each plugin's onDestroy function, if it has one", function(done) {
            var b;
            b = new core.AnnotatorCore();
            b.addPlugin(MockPlugin);
            b.addPlugin(MockPlugin);
            b.addPlugin(MockEmptyPlugin);
            return b.destroy().then(function() {
                var result;
                result = b.plugins.map(function(p) {
                    return p.destroyed;
                });
                return assert.deepEqual([true, true, void 0], result);
            }).then(done, done);
        });
    });
    describe('#runHook', function() {
        it('should run the named hook handler on each plugin', function() {
            var b, pluginOne, pluginThree, pluginTwo;
            b = new core.AnnotatorCore();
            b.addPlugin(MockPlugin);
            pluginOne = MockPlugin.lastInstance;
            b.addPlugin(MockPlugin);
            pluginTwo = MockPlugin.lastInstance;
            b.addPlugin(MockPlugin);
            pluginThree = MockPlugin.lastInstance;
            // Remove the hook handler on this plugin
            delete pluginThree.onAnnotationCreated;
            b.runHook('onAnnotationCreated');
            assert.deepEqual(pluginOne.hookCalls, [['onAnnotationCreated', []]]);
            return assert.deepEqual(pluginTwo.hookCalls, [['onAnnotationCreated', []]]);
        });
        it('should return a promise that resolves if all the ' + 'handlers resolve', function(done) {
            var b, delayedResolve, pluginOne, pluginThree, pluginTwo, ret;
            b = new core.AnnotatorCore();
            b.addPlugin(MockPlugin);
            pluginOne = MockPlugin.lastInstance;
            b.addPlugin(MockPlugin);
            pluginTwo = MockPlugin.lastInstance;
            b.addPlugin(MockPlugin);
            pluginThree = MockPlugin.lastInstance;
            pluginOne.hookResult = 123;
            pluginTwo.hookResult = Promise.resolve("ok");
            delayedResolve = null;
            pluginThree.hookResult = new Promise(function(resolve, reject) {
                return delayedResolve = resolve;
            });
            ret = b.runHook('onAnnotationCreated');
            ret.then(function() {
                return done();
            }, function() {
                return done(new Error("Promise should not have been rejected!"));
            });
            return delayedResolve("finally...");
        });
        return it('should return a promise that rejects if any handler rejects', function(done) {
            var b, delayedReject, pluginOne, pluginTwo, ret;
            b = new core.AnnotatorCore();
            b.addPlugin(MockPlugin);
            pluginOne = MockPlugin.lastInstance;
            b.addPlugin(MockPlugin);
            pluginTwo = MockPlugin.lastInstance;
            pluginOne.hookResult = Promise.resolve("ok");
            delayedReject = null;
            pluginTwo.hookResult = new Promise(function(resolve, reject) {
                return delayedReject = reject;
            });
            ret = b.runHook('onAnnotationCreated');
            ret.then(function() {
                return done(new Error("Promise should not have been resolved!"));
            }, function() {
                return done();
            });
            return delayedReject("fail...");
        });
    });
    describe('#setNotification', function() {
        return it('should set registry `notification` to the return value of the notification function', function() {
            var b;
            b = new core.AnnotatorCore();
            b.setNotification(MockNotification);
            return assert.strictEqual(b.registry.notification, MockNotificationObj);
        });
    });
    return describe('#setStorage', function() {
        it('should call the storage function', function() {
            var b;
            b = new core.AnnotatorCore();
            b._storageAdapterType = MockStorageAdapter;
            b.setStorage(MockStorage);
            return assert.ok(MockStorage.lastInstance);
        });
        it('should set registry `annotations` to be a storage adapter', function() {
            var b;
            b = new core.AnnotatorCore();
            b._storageAdapterType = MockStorageAdapter;
            b.setStorage(MockStorage);
            return assert.strictEqual(MockStorageAdapter.lastInstance, b.registry.annotations);
        });
        it('should pass the adapter the return value of the storage function', function() {
            var b;
            b = new core.AnnotatorCore();
            b._storageAdapterType = MockStorageAdapter;
            b.setStorage(MockStorage);
            return assert.strictEqual(MockStorageAdapter.lastInstance.storage, MockStorage.lastInstance);
        });
        return it('should pass the adapter a hook runner which calls the runHook method of the annotator', function() {
            var b;
            b = new core.AnnotatorCore();
            b._storageAdapterType = MockStorageAdapter;
            sinon.spy(b, 'runHook');
            b.setStorage(MockStorage);
            MockStorageAdapter.lastInstance.hookRunner('foo', [1, 2, 3]);
            sinon.assert.calledWith(b.runHook, 'foo', [1, 2, 3]);
            return b.runHook.restore();
        });
    });
});
