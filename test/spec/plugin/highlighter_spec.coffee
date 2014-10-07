var Highlighter;

Highlighter = require('../../../src/plugin/highlighter').Highlighter;

describe('Highlighter plugin', function() {
    var ann, mockElement, mockHighlighter, plugin, sandbox;
    ann = null;
    mockElement = null;
    mockHighlighter = null;
    plugin = null;
    sandbox = null;
    beforeEach(function() {
        var mockHighlighterCtor;
        sandbox = sinon.sandbox.create();
        ann = {
            id: 'abc123',
            ranges: [
                {
                    start: '/p[1]',
                    startOffset: 0,
                    end: '/p[1]',
                    endOffset: 12
                }
            ]
        };
        mockElement = {};
        mockHighlighter = {
            draw: sandbox.stub(),
            undraw: sandbox.stub(),
            redraw: sandbox.stub(),
            drawAll: sandbox.stub(),
            destroy: sandbox.stub()
        };
        mockHighlighterCtor = sandbox.stub();
        mockHighlighterCtor.returns(mockHighlighter);
        // Create a new plugin object. The Highlighter plugin doesn't use the
        // registry, so we can just pass null.
        return plugin = Highlighter(mockElement, {}, mockHighlighterCtor)(null);
    });
    afterEach(function() {
        return sandbox.restore();
    });
    it('should draw highlights onAnnotationCreated', function() {
        plugin.onAnnotationCreated(ann);
        return sinon.assert.calledWith(mockHighlighter.draw, ann);
    });
    it('should redraw highlights onAnnotationUpdated', function() {
        plugin.onAnnotationUpdated(ann);
        return sinon.assert.calledWith(mockHighlighter.redraw, ann);
    });
    it('should undraw highlights onAnnotationDeleted', function() {
        plugin.onAnnotationDeleted(ann);
        return sinon.assert.calledWith(mockHighlighter.undraw, ann);
    });
    it('should draw all highlights onAnnotationsLoaded', function() {
        var ann2;
        ann2 = {
            id: 'def456',
            ranges: [
                {
                    start: '/p[2]',
                    startOffset: 0,
                    end: '/p[2]',
                    endOffset: 20
                }
            ]
        };
        plugin.onAnnotationsLoaded([ann, ann2]);
        return sinon.assert.calledWith(mockHighlighter.drawAll, [ann, ann2]);
    });
    return it('destroys the highlighter component when destroyed', function() {
        plugin.onDestroy();
        return sinon.assert.calledOnce(mockHighlighter.destroy);
    });
});
