var assert = require('assertive-chai').assert;

var h = require('../../helpers');

var $ = require('../../../src/util').$;

var DefaultUI = require('../../../src/plugin/defaultui').DefaultUI,
    UI = require('../../../src/ui');

describe('DefaultUI plugin', function () {
    var sandbox;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
    });

    afterEach(function () {
        sandbox.restore();
        h.clearFixtures();
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

        var plug = DefaultUI(h.fix())(null);
        check(1000);
        plug.onDestroy();

        $fix.append('<div style="position: relative; z-index: 2000"></div>');
        plug = DefaultUI(h.fix())(null);
        check(2000);
        plug.onDestroy();
    });

    describe("Adder", function () {
        var el, mockAdder, mockRegistry, plug;

        beforeEach(function () {
            el = $('<div></div>')[0];
            mockAdder = {destroy: sandbox.stub(), attach: sandbox.stub()};
            mockRegistry = {annotations: {create: sandbox.stub()}};
            sandbox.stub(UI, 'Adder').returns(mockAdder);

            plug = DefaultUI(el)(mockRegistry);
        });

        afterEach(function () {
            plug.onDestroy();
        });

        it("creates an Adder", function () {
            sinon.assert.calledOnce(UI.Adder);
        });

        it("passes an onCreate handler which asks the registry to create an annotation", function () {
            var callArgs = UI.Adder.args[0];
            assert.property(callArgs[0], 'onCreate');
            callArgs[0].onCreate({text: 'wibble'});
            sinon.assert.calledWith(
                mockRegistry.annotations.create,
                {text: 'wibble'}
            );
        });
    });

    describe("Editor", function () {
        var el, mockEditor, mockRegistry, plug;

        beforeEach(function () {
            el = $('<div></div>')[0];
            mockEditor = {
                addField: sandbox.stub(),
                destroy: sandbox.stub(),
                attach: sandbox.stub()
            };
            mockRegistry = {
                annotations: {create: sandbox.stub()},
                authorizer: {
                    permits: sandbox.stub().returns(true),
                    userId: function (u) { return u; }
                },
                identifier: {who: sandbox.stub().returns('alice')}
            };
            sandbox.stub(UI, 'Editor').returns(mockEditor);

            plug = DefaultUI(el)(mockRegistry);
        });

        afterEach(function () {
            plug.onDestroy();
        });

        it("creates an Editor", function () {
            sinon.assert.calledOnce(UI.Editor);
        });

        it("adds permissions-related fields", function () {
            sinon.assert.callCount(mockEditor.addField, 2);
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
                mockRegistry.identifier.who.returns(null);
                viewLoad(field, {});
                assert.equal(field.style.display, 'none');
            });

            it("load hides a field if current user is not admin", function () {
                var ann = {};
                mockRegistry.authorizer.permits
                    .withArgs('admin', ann, 'alice').returns(false);
                viewLoad(field, ann);
                assert.equal(field.style.display, 'none');
            });

            it("load hides a field if current user is not admin", function () {
                var ann = {};
                mockRegistry.authorizer.permits
                    .withArgs('admin', ann, 'alice').returns(false);
                viewLoad(field, ann);
                assert.equal(field.style.display, 'none');
            });

            it("load shows a checked field if the action is authorised with a null user", function () {
                mockRegistry.authorizer.permits.returns(true);
                viewLoad(field, {});
                assert.notEqual(field.style.display, 'none');
                assert.isTrue(field.firstChild.checked);
            });

            it("load shows an unchecked field if the action isn't authorised with a null user", function () {
                var ann = {};
                mockRegistry.authorizer.permits
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
                mockRegistry.identifier.who.returns(null);
                var ann = {permissions: {'read': ['alice']}};
                field.firstChild.checked = true;
                viewSubmit(field, ann);
                assert.deepEqual(ann.permissions, {'read': ['alice']});
            });
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
        sandbox.stub(UI, 'Adder').returns(mockAdder);
        sandbox.stub(UI, 'Editor').returns(mockEditor);
        sandbox.stub(UI, 'Highlighter').returns(mockHighlighter);
        sandbox.stub(UI, 'TextSelector').returns(mockTextSelector);
        sandbox.stub(UI, 'Viewer').returns(mockViewer);
        var plug = DefaultUI(null)(null);
        plug.onDestroy();
        sinon.assert.calledOnce(mockAdder.destroy);
        sinon.assert.calledOnce(mockEditor.destroy);
        sinon.assert.calledOnce(mockHighlighter.destroy);
        sinon.assert.calledOnce(mockTextSelector.destroy);
        sinon.assert.calledOnce(mockViewer.destroy);
    });
});
