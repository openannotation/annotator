var filter = require('../../../src/plugin/filter').filter;
var annotator = require('annotator');

describe('filter plugin', function () {
    var mockFilter = null,
        plugin = null,
        sandbox = null;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        mockFilter = {
            updateHighlights: sandbox.stub(),
            destroy: sandbox.stub()
        };

        sandbox.stub(annotator.ui, 'Filter').returns(mockFilter);

        plugin = filter();
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
        plugin.destroy();
        sinon.assert.calledOnce(mockFilter.destroy);
    });
});
