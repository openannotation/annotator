var assert = require('assertive-chai').assert;

var Editor = require('../../../src/plugin/editor').Editor;

describe('Editor plugin', function () {
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

        var mockEditorCtor = sandbox.stub();
        mockEditorCtor.returns(mockEditor);

        // Create a new plugin object. The editor plugin doesn't use the registry,
        // so we can just pass null.
        plugin = Editor({}, mockEditorCtor)(null);
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
        plugin.onDestroy();
        sinon.assert.calledOnce(mockEditor.destroy);
    });
});
