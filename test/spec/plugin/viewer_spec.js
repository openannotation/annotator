var assert = require('assertive-chai').assert;

var viewer = require('../../../src/plugin/viewer').viewer;
var annotator = require('annotator');

describe('viewer plugin', function () {
    var mockRegistry = null,
        mockViewer = null,
        sandbox = null;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        mockRegistry = {
            annotations: {
                update: sandbox.stub(),
                "delete": sandbox.stub()
            },
            authz: {
                permits: sandbox.stub()
            },
            ident: {
                who: sandbox.stub().returns('alice')
            }
        };
        mockViewer = {
            destroy: sandbox.stub()
        };
        sandbox.stub(annotator.ui, 'Viewer').returns(mockViewer);
    });

    afterEach(function () {
        sandbox.restore();
    });

    it('sets a default onEdit handler that calls the storage update function', function () {
        viewer().configure(mockRegistry);
        var passedOptions = annotator.ui.Viewer.firstCall.args[0];
        assert(sinon.match.has('onEdit').test(passedOptions));
        passedOptions.onEdit({
            text: 'foo'
        });
        sinon.assert.calledWith(mockRegistry.annotations.update, {
            text: 'foo'
        });
    });

    it('sets a default onDelete handler that calls the storage delete function', function () {
        viewer().configure(mockRegistry);
        var passedOptions = annotator.ui.Viewer.firstCall.args[0];
        assert(sinon.match.has('onDelete').test(passedOptions));
        passedOptions.onDelete({
            text: 'foo'
        });
        sinon.assert.calledWith(mockRegistry.annotations["delete"], {
            text: 'foo'
        });
    });

    it('sets a default permitEdit handler that consults the authorization policy', function () {
        viewer().configure(mockRegistry);
        var passedOptions = annotator.ui.Viewer.firstCall.args[0];
        assert(sinon.match.has('permitEdit').test(passedOptions));
        passedOptions.permitEdit({text: 'foo'});
        sinon.assert.calledWith(
            mockRegistry.authz.permits,
            'update',
            {text: 'foo'},
            'alice'
        );
    });

    it('sets a default permitDelete handler that consults the authorization policy', function () {
        viewer().configure(mockRegistry);
        var passedOptions = annotator.ui.Viewer.firstCall.args[0];
        assert(sinon.match.has('permitDelete').test(passedOptions));
        passedOptions.permitDelete({text: 'foo'});
        sinon.assert.calledWith(
            mockRegistry.authz.permits,
            'delete',
            {text: 'foo'},
            'alice'
        );
    });

    it('destroys the viewer component when destroyed', function () {
        var plugin = viewer();
        plugin.configure(mockRegistry);
        plugin.destroy();
        sinon.assert.calledOnce(mockViewer.destroy);
    });
});
