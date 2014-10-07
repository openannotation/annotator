var Editor;

Editor = require('../../../src/plugin/editor').Editor;

describe('Editor plugin', function() {
    var ann, mockEditor, plugin, sandbox;
    ann = null;
    mockEditor = null;
    plugin = null;
    sandbox = null;
    beforeEach(function() {
        var mockEditorCtor;
        sandbox = sinon.sandbox.create();
        ann = {
            id: 'abc123',
            text: 'hello there'
        };
        mockEditor = {
            load: sandbox.stub().returns("a promise, honest"),
            destroy: sandbox.stub()
        };
        mockEditorCtor = sandbox.stub();
        mockEditorCtor.returns(mockEditor);
        // Create a new plugin object. The editor plugin doesn't use the registry,
        // so we can just pass null.
        return plugin = Editor({}, mockEditorCtor)(null);
    });
    afterEach(function() {
        return sandbox.restore();
    });
    it('loads an annotation into the editor component onBeforeAnnotationCreated', function() {
        var result;
        result = plugin.onBeforeAnnotationCreated(ann);
        sinon.assert.calledWith(mockEditor.load, ann);
        return assert.equal(result, "a promise, honest");
    });
    it('loads an annotation into the editor component onBeforeAnnotationUpdated', function() {
        var result;
        result = plugin.onBeforeAnnotationUpdated(ann);
        sinon.assert.calledWith(mockEditor.load, ann);
        return assert.equal(result, "a promise, honest");
    });
    return it('destroys the editor component when destroyed', function() {
        plugin.onDestroy();
        return sinon.assert.calledOnce(mockEditor.destroy);
    });
});
