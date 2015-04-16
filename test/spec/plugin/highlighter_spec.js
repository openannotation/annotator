var highlighter = require('../../../src/plugin/highlighter').highlighter;
var annotator = require('annotator');

describe('highlighter plugin', function () {
    var ann = null,
        mockElement = null,
        mockHighlighter = null,
        plugin = null,
        sandbox = null;

    beforeEach(function () {
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

        sandbox.stub(annotator.ui, 'Highlighter').returns(mockHighlighter);

        plugin = highlighter(mockElement);
    });

    afterEach(function () {
        sandbox.restore();
    });

    it('should draw highlights annotationCreated', function () {
        plugin.annotationCreated(ann);
        sinon.assert.calledWith(mockHighlighter.draw, ann);
    });

    it('should redraw highlights annotationUpdated', function () {
        plugin.annotationUpdated(ann);
        sinon.assert.calledWith(mockHighlighter.redraw, ann);
    });

    it('should undraw highlights annotationDeleted', function () {
        plugin.annotationDeleted(ann);
        sinon.assert.calledWith(mockHighlighter.undraw, ann);
    });

    it('should draw all highlights annotationsLoaded', function () {
        var ann2 = {
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
        plugin.annotationsLoaded([ann, ann2]);
        sinon.assert.calledWith(mockHighlighter.drawAll, [ann, ann2]);
    });

    it('destroys the highlighter component when destroyed', function () {
        plugin.destroy();
        sinon.assert.calledOnce(mockHighlighter.destroy);
    });
});
