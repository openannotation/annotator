var Filter = require('../../../src/plugin/filter').Filter;

describe('Filter plugin', function () {
    var mockFilter = null,
        plugin = null,
        sandbox = null;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        mockFilter = {
            updateHighlights: sandbox.stub(),
            destroy: sandbox.stub()
        };

        var mockFilterCtor = sandbox.stub();
        mockFilterCtor.returns(mockFilter);

        // Create a new plugin object. The Filter plugin doesn't use the registry,
        // so we can just pass null.
        plugin = Filter({}, mockFilterCtor)(null);
    });

    afterEach(function () {
        sandbox.restore();
    });

    var hooks = [
        'onAnnotationsLoaded',
        'onAnnotationCreated',
        'onAnnotationUpdated',
        'onAnnotationDeleted'
    ];

    function testHook(h) {
        return function () {
            plugin[h]({text: 123});
            sinon.assert.calledWith(mockFilter.updateHighlights);
        };
    }

    for (var i = 0, len = hooks.length; i < len; i++) {
        it(
            "calls updateHighlights on the filter component " + hooks[i],
            testHook(hooks[i])
        );
    }

    it('destroys the filter component when destroyed', function () {
        plugin.onDestroy();
        sinon.assert.calledOnce(mockFilter.destroy);
    });
});
