var assert = require('assertive-chai').assert;

var editor = require('../../../src/plugin/editor').editor;
var annotator = require('annotator');

describe('editor plugin', function () {
    var ann = null,
        mockEditor = null,
        plugin = null,
        sandbox = null;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        ann = {
            id: 'abc123',
            text: 'hello there'
        };
        mockEditor = {
            load: sandbox.stub().returns("a promise, honest"),
            destroy: sandbox.stub()
        };

        sandbox.stub(annotator.ui, 'Editor').returns(mockEditor);

        plugin = editor();
    });

    afterEach(function () {
        sandbox.restore();
    });

    it('loads an annotation into the editor component onBeforeAnnotationCreated', function () {
        var result = plugin.onBeforeAnnotationCreated(ann);
        sinon.assert.calledWith(mockEditor.load, ann);
        assert.equal(result, "a promise, honest");
    });

    it('loads an annotation into the editor component onBeforeAnnotationUpdated', function () {
        var result = plugin.onBeforeAnnotationUpdated(ann);
        sinon.assert.calledWith(mockEditor.load, ann);
        assert.equal(result, "a promise, honest");
    });

    it('destroys the editor component when destroyed', function () {
        plugin.destroy();
        sinon.assert.calledOnce(mockEditor.destroy);
    });
});
