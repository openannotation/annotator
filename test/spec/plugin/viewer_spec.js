var Viewer;

Viewer = require('../../../src/plugin/viewer').Viewer;

describe('Viewer plugin', function() {
    var ann, mockRegistry, mockViewer, mockViewerCtor, sandbox;
    ann = null;
    mockRegistry = null;
    mockViewer = null;
    mockViewerCtor = null;
    sandbox = null;
    beforeEach(function() {
        sandbox = sinon.sandbox.create();
        mockRegistry = {
            annotations: {
                update: sandbox.stub(),
                "delete": sandbox.stub()
            }
        };
        mockViewer = {
            destroy: sandbox.stub()
        };
        mockViewerCtor = sandbox.stub();
        return mockViewerCtor.returns(mockViewer);
    });
    afterEach(function() {
        return sandbox.restore();
    });
    it('sets a default onEdit handler that calls the storage update function', function() {
        var passedOptions, plugin;
        plugin = Viewer({}, mockViewerCtor)(mockRegistry);
        passedOptions = mockViewerCtor.firstCall.args[0];
        assert(sinon.match.has('onEdit').test(passedOptions));
        passedOptions.onEdit({
            text: 'foo'
        });
        return sinon.assert.calledWith(mockRegistry.annotations.update, {
            text: 'foo'
        });
    });
    it('sets a default onDelete handler that calls the storage delete function', function() {
        var passedOptions, plugin;
        plugin = Viewer({}, mockViewerCtor)(mockRegistry);
        passedOptions = mockViewerCtor.firstCall.args[0];
        assert(sinon.match.has('onDelete').test(passedOptions));
        passedOptions.onDelete({
            text: 'foo'
        });
        return sinon.assert.calledWith(mockRegistry.annotations["delete"], {
            text: 'foo'
        });
    });
    return it('destroys the viewer component when destroyed', function() {
        var plugin;
        plugin = Viewer({}, mockViewerCtor)(mockRegistry);
        plugin.onDestroy();
        return sinon.assert.calledOnce(mockViewer.destroy);
    });
});
