var h = require('helpers');

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

        $fix.append('<div style="position: relative; z-index: 2000"></div>');
        plug = DefaultUI(h.fix())(null);
        check(2000);
    });

    describe("Adder", function () {
        var el, mockAdder, mockRegistry, plug;

        beforeEach(function () {
            el = $('<div></div>')[0];
            mockAdder = {destroy: sandbox.stub()};
            mockRegistry = {annotations: {create: sandbox.stub()}};
            sandbox.stub(UI, 'Adder').returns(mockAdder);

            plug = DefaultUI(el)(mockRegistry);
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
                destroy: sandbox.stub()
            };
            mockRegistry = {annotations: {create: sandbox.stub()}};
            sandbox.stub(UI, 'Editor').returns(mockEditor);

            plug = DefaultUI(el)(mockRegistry);
        });

        it("creates an Editor", function () {
            sinon.assert.calledOnce(UI.Editor);
        });
    });

    it("should destroy the UI components when it is destroyed", function () {
        var mockAdder = {destroy: sandbox.stub()},
            mockEditor = {addField: sandbox.stub(), destroy: sandbox.stub()},
            mockHighlighter = {destroy: sandbox.stub()},
            mockTextSelector = {destroy: sandbox.stub()},
            mockViewer = {destroy: sandbox.stub()};
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
