var assert = require('assertive-chai').assert;

var h = require('../../helpers');

var $ = require('../../../src/util').$;

// Import dependent components so we can stub them out
var adder = require('../../../src/ui/adder');
var editor = require('../../../src/ui/editor');
var highlighter = require('../../../src/ui/highlighter');
var textselector = require('../../../src/ui/textselector');
var viewer = require('../../../src/ui/viewer');

var main = require('../../../src/ui/main').main;

describe('annotator.ui.main', function () {
    var sandbox;
    var mockAuthz;
    var mockIdent;
    var mockApp;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        mockAuthz = {
            permits: sandbox.stub().returns(true),
            authorizedUserId: function (u) { return u; }
        };
        mockIdent = {who: sandbox.stub().returns('alice')};
        mockApp = {
            annotations: {create: sandbox.stub()},
            registry: {
                getUtility: sandbox.stub()
            }
        };
        mockApp.registry.getUtility.withArgs('authorizationPolicy').returns(mockAuthz);
        mockApp.registry.getUtility.withArgs('identityPolicy').returns(mockIdent);
    });

    afterEach(function () {
        sandbox.restore();
        h.clearFixtures();
    });

    it('should attach the TextSelector to the document body by default', function () {
        sandbox.stub(textselector, 'TextSelector');

        var plug = main();
        plug.start(mockApp);

        sinon.assert.calledWith(textselector.TextSelector, document.body);
    });

    it('should add CSS to the document that ensures annotator elements have a suitably high z-index', function () {
        h.addFixture('annotator');
        var $fix = $(h.fix());
        $fix.show();

        var $adder = $('<div style="position:relative;" class="annotator-adder">&nbsp;</div>').appendTo($fix);
        var $filter = $('<div style="position:relative;" class="annotator-filter">&nbsp;</div>').appendTo($fix);

        function check(minimum) {
            var adderZ, filterZ;
            adderZ = parseInt($adder.css('z-index'), 10);
            filterZ = parseInt($filter.css('z-index'), 10);
            assert.operator(adderZ, '>', minimum);
            assert.operator(filterZ, '>', minimum);
            return assert.operator(adderZ, '>', filterZ);
        }

        var plug = main({element: h.fix()});
        plug.start(mockApp);
        check(1000);
        plug.destroy();

        $fix.append('<div style="position: relative; z-index: 2000"></div>');
        plug = main({element: h.fix()});
        plug.start(mockApp);
        check(2000);
        plug.destroy();
    });

    describe("Adder", function () {
        var el, mockAdder, plug;

        beforeEach(function () {
            el = $('<div></div>')[0];
            mockAdder = {destroy: sandbox.stub(), attach: sandbox.stub()};
            sandbox.stub(adder, 'Adder').returns(mockAdder);

            plug = main({element: el});
            plug.start(mockApp);
        });

        afterEach(function () {
            plug.destroy();
        });

        it("creates an Adder", function () {
            sinon.assert.calledOnce(adder.Adder);
        });

        it("passes an onCreate handler which asks the app to create an annotation", function () {
            var callArgs = adder.Adder.args[0];
            assert.property(callArgs[0], 'onCreate');
            callArgs[0].onCreate({text: 'wibble'});
            sinon.assert.calledWith(
                mockApp.annotations.create,
                {text: 'wibble'}
            );
        });
    });

    describe("Editor", function () {
        var el, mockEditor, plug;

        beforeEach(function () {
            el = $('<div></div>')[0];
            mockEditor = {
                addField: sandbox.stub(),
                destroy: sandbox.stub(),
                attach: sandbox.stub()
            };
            sandbox.stub(editor, 'Editor').returns(mockEditor);

            plug = main({element: el});
            plug.start(mockApp);
        });

        afterEach(function () {
            plug.destroy();
        });

        it("creates an Editor", function () {
            sinon.assert.calledOnce(editor.Editor);
        });

        it("adds permissions-related fields", function () {
            sinon.assert.callCount(mockEditor.addField, 2);
        });

        it("passes editorExtensions on to the editor", function () {
            editor.Editor.reset();
            plug = main({
                element: el,
                editorExtensions: ['foo', 'bar']
            });
            plug.start(mockApp);

            sinon.assert.calledWith(editor.Editor,
                                    sinon.match.has('extensions', ['foo', 'bar']));
        });

        describe("permissions field load/submit functions", function () {
            var field;
            var viewLoad, viewSubmit;

            beforeEach(function () {
                viewLoad = mockEditor.addField.args[0][0].load;
                viewSubmit = mockEditor.addField.args[0][0].submit;

                field = $('<div><input type="checkbox" disabled></div>')[0];
            });

            it("load hides a field if no user is set", function () {
                mockIdent.who.returns(null);
                viewLoad(field, {});
                assert.equal(field.style.display, 'none');
            });

            it("load hides a field if current user is not admin", function () {
                var ann = {};
                mockAuthz.permits
                    .withArgs('admin', ann, 'alice').returns(false);
                viewLoad(field, ann);
                assert.equal(field.style.display, 'none');
            });

            it("load hides a field if current user is not admin", function () {
                var ann = {};
                mockAuthz.permits
                    .withArgs('admin', ann, 'alice').returns(false);
                viewLoad(field, ann);
                assert.equal(field.style.display, 'none');
            });

            it("load shows a checked field if the action is authorised with a null user", function () {
                mockAuthz.permits.returns(true);
                viewLoad(field, {});
                assert.notEqual(field.style.display, 'none');
                assert.isTrue(field.firstChild.checked);
            });

            it("load shows an unchecked field if the action isn't authorised with a null user", function () {
                var ann = {};
                mockAuthz.permits
                    .withArgs('read', ann, null).returns(false);
                viewLoad(field, ann);
                assert.notEqual(field.style.display, 'none');
                assert.isFalse(field.firstChild.checked);
            });

            it("submit deletes the permissions field for the action if the checkbox is checked", function () {
                var ann = {permissions: {'read': ['alice']}};
                field.firstChild.checked = true;
                viewSubmit(field, ann);
                assert.notProperty(ann.permissions, 'read');
            });

            it("submit sets the permissions field for the action to [userId] if the checkbox is unchecked", function () {
                var ann = {};
                field.firstChild.checked = false;
                viewSubmit(field, ann);
                assert.property(ann, 'permissions');
                assert.property(ann.permissions, 'read');
                assert.deepEqual(ann.permissions.read, ['alice']);
            });

            it("submit doesn't touch the annotation if the current user is null", function () {
                mockIdent.who.returns(null);
                var ann = {permissions: {'read': ['alice']}};
                field.firstChild.checked = true;
                viewSubmit(field, ann);
                assert.deepEqual(ann.permissions, {'read': ['alice']});
            });
        });
    });

    describe("Viewer", function () {
        var el, mockViewer, plug;

        beforeEach(function () {
            el = $('<div></div>')[0];
            mockViewer = {
                addField: sandbox.stub(),
                destroy: sandbox.stub(),
                attach: sandbox.stub()
            };
            sandbox.stub(viewer, 'Viewer').returns(mockViewer);

            plug = main({element: el});
            plug.start(mockApp);
        });

        afterEach(function () {
            plug.destroy();
        });

        it("creates a Viewer", function () {
            sinon.assert.calledOnce(viewer.Viewer);
        });

        it("passes viewerExtensions on to the viewer", function () {
            viewer.Viewer.reset();
            plug = main({
                element: el,
                viewerExtensions: ['bar', 'baz']
            });
            plug.start(mockApp);

            sinon.assert.calledWith(viewer.Viewer,
                                    sinon.match.has('extensions', ['bar', 'baz']));
        });
    });

    it("should destroy the UI components when it is destroyed", function () {
        var mockAdder = {destroy: sandbox.stub(), attach: sandbox.stub()},
            mockEditor = {
                addField: sandbox.stub(),
                destroy: sandbox.stub(),
                attach: sandbox.stub()
            },
            mockHighlighter = {destroy: sandbox.stub()},
            mockTextSelector = {destroy: sandbox.stub()},
            mockViewer = {destroy: sandbox.stub(), attach: sandbox.stub()};
        sandbox.stub(adder, 'Adder').returns(mockAdder);
        sandbox.stub(editor, 'Editor').returns(mockEditor);
        sandbox.stub(highlighter, 'Highlighter').returns(mockHighlighter);
        sandbox.stub(textselector, 'TextSelector').returns(mockTextSelector);
        sandbox.stub(viewer, 'Viewer').returns(mockViewer);
        var plug = main();
        plug.start(mockApp);
        plug.destroy();
        sinon.assert.calledOnce(mockAdder.destroy);
        sinon.assert.calledOnce(mockEditor.destroy);
        sinon.assert.calledOnce(mockHighlighter.destroy);
        sinon.assert.calledOnce(mockTextSelector.destroy);
        sinon.assert.calledOnce(mockViewer.destroy);
    });
});
