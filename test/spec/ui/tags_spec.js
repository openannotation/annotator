var assert = require('assertive-chai').assert;

var tags = require('../../../src/ui/tags');
var util = require('../../../src/util');

var $ = util.$;


describe('ui.tags.viewerExtension', function () {
    var mockViewer;

    beforeEach(function () {
        mockViewer = {
            addField: sinon.stub()
        };
    });

    it("calls addField with a load callback", function () {
        tags.viewerExtension(mockViewer);

        sinon.assert.calledWith(mockViewer.addField,
                                sinon.match.has('load', sinon.match.func));
    });

    it("field load callback inserts the tags into the field", function () {
        tags.viewerExtension(mockViewer);
        var load = mockViewer.addField.firstCall.args[0].load;

        var annotation = {
            tags: ['foo', 'bar', 'baz']
        };
        var field = $('<div />')[0];

        load(field, annotation);

        assert.deepEqual($(field).html(), [
            '<span class="annotator-tag">foo</span>',
            '<span class="annotator-tag">bar</span>',
            '<span class="annotator-tag">baz</span>'
        ].join(' '));
    });

    it("field load callback removes the field if there are no tags", function () {
        tags.viewerExtension(mockViewer);
        var load = mockViewer.addField.firstCall.args[0].load;

        var annotation = {
            tags: []
        };
        var field = $('<div />')[0];

        load(field, annotation);

        assert.lengthOf($(field).parent(), 0);
        annotation = {};
        field = $('<div />')[0];
        load(field, annotation);
        assert.lengthOf($(field).parent(), 0);
    });
});


describe('ui.tags.editorExtension', function () {
    var sandbox;
    var mockField;
    var mockInput;
    var mockEditor;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        mockField = {};
        mockInput = {
            val: sandbox.stub()
        };
        mockEditor = {
            addField: sandbox.stub().returns(mockField)
        };
        sandbox.stub($.fn, 'init');
        $.fn.init.withArgs(mockField).returns({
            find: sandbox.stub().returns(mockInput)
        });
    });

    afterEach(function () {
        sandbox.restore();
    });

    it("calls addField with a load callback", function () {
        tags.editorExtension(mockEditor);

        sinon.assert.calledWith(mockEditor.addField,
                                sinon.match.has('load', sinon.match.func));
    });

    it("calls addField with a submit callback", function () {
        tags.editorExtension(mockEditor);

        sinon.assert.calledWith(mockEditor.addField,
                                sinon.match.has('submit', sinon.match.func));
    });

    it("calls addField with a label", function () {
        tags.editorExtension(mockEditor);

        sinon.assert.calledWith(mockEditor.addField,
                                sinon.match.has('label', sinon.match.string));
    });

    it("field load callback should set the input field value", function () {
        tags.editorExtension(mockEditor);
        var load = mockEditor.addField.firstCall.args[0].load;

        var annotation = {
            tags: ['one', 'two', 'three']
        };

        load({}, annotation);
        sinon.assert.calledWith(mockInput.val, "one two three");
    });

    it("field load callback should clear input field if there are no tags", function () {
        tags.editorExtension(mockEditor);
        var load = mockEditor.addField.firstCall.args[0].load;

        var annotation = {};

        load({}, annotation);
        sinon.assert.calledWith(mockInput.val, "");
    });

    it("field submit callback should set the annotation tags property", function () {
        tags.editorExtension(mockEditor);
        var submit = mockEditor.addField.firstCall.args[0].submit;

        mockInput.val.returns('one two  three\tfourFive');

        var annotation = {};
        submit({}, annotation);
        assert.deepEqual(annotation.tags, ['one', 'two', 'three', 'fourFive']);
    });
});
