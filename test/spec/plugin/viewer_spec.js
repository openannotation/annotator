var assert = require('assertive-chai').assert;

var viewer = require('../../../src/plugin/viewer').viewer;
var annotator = require('annotator');

describe('viewer plugin', function () {
    var mockApp = null,
        mockViewer = null,
        sandbox = null;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        mockApp = {
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
        viewer().start(mockApp);
        var passedOptions = annotator.ui.Viewer.firstCall.args[0];
        assert(sinon.match.has('onEdit').test(passedOptions));
        passedOptions.onEdit({
            text: 'foo'
        });
        sinon.assert.calledWith(mockApp.annotations.update, {
            text: 'foo'
        });
    });

    it('sets a default onDelete handler that calls the storage delete function', function () {
        viewer().start(mockApp);
        var passedOptions = annotator.ui.Viewer.firstCall.args[0];
        assert(sinon.match.has('onDelete').test(passedOptions));
        passedOptions.onDelete({
            text: 'foo'
        });
        sinon.assert.calledWith(mockApp.annotations["delete"], {
            text: 'foo'
        });
    });

    it('sets a default permitEdit handler that consults the authorization policy', function () {
        viewer().start(mockApp);
        var passedOptions = annotator.ui.Viewer.firstCall.args[0];
        assert(sinon.match.has('permitEdit').test(passedOptions));
        passedOptions.permitEdit({text: 'foo'});
        sinon.assert.calledWith(
            mockApp.authz.permits,
            'update',
            {text: 'foo'},
            'alice'
        );
    });

    it('sets a default permitDelete handler that consults the authorization policy', function () {
        viewer().start(mockApp);
        var passedOptions = annotator.ui.Viewer.firstCall.args[0];
        assert(sinon.match.has('permitDelete').test(passedOptions));
        passedOptions.permitDelete({text: 'foo'});
        sinon.assert.calledWith(
            mockApp.authz.permits,
            'delete',
            {text: 'foo'},
            'alice'
        );
    });

    it('destroys the viewer component when destroyed', function () {
        var plugin = viewer();
        plugin.start(mockApp);
        plugin.destroy();
        sinon.assert.calledOnce(mockViewer.destroy);
    });
});
