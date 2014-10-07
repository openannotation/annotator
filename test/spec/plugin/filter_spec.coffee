var Filter;

Filter = require('../../../src/plugin/filter').Filter;

describe('Filter plugin', function() {
    var ann, mockFilter, plugin, sandbox, x, _i, _len, _ref;
    ann = null;
    mockFilter = null;
    plugin = null;
    sandbox = null;
    beforeEach(function() {
        var mockFilterCtor;
        sandbox = sinon.sandbox.create();
        mockFilter = {
            updateHighlights: sandbox.stub(),
            destroy: sandbox.stub()
        };
        mockFilterCtor = sandbox.stub();
        mockFilterCtor.returns(mockFilter);
        // Create a new plugin object. The Filter plugin doesn't use the registry,
        // so we can just pass null.
        return plugin = Filter({}, mockFilterCtor)(null);
    });
    afterEach(function() {
        return sandbox.restore();
    });
    _ref = ['onAnnotationsLoaded', 'onAnnotationCreated', 'onAnnotationUpdated', 'onAnnotationDeleted'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        x = _ref[_i];
        it("calls updateHighlights on the filter component " + x, function() {
            var result;
            result = plugin[x]({
                text: 123
            });
            return sinon.assert.calledWith(mockFilter.updateHighlights);
        });
    }
    return it('destroys the filter component when destroyed', function() {
        plugin.onDestroy();
        return sinon.assert.calledOnce(mockFilter.destroy);
    });
});
