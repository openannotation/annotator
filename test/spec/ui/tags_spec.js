var assert = require('assertive-chai').assert;

var tags = require('../../../src/ui/tags');
var editor = require('../../../src/ui/editor');
var viewer = require('../../../src/ui/viewer');
var util = require('../../../src/util');

var $ = util.$;

describe('ui.tags.tags', function () {
    var t = null;
    var sandbox = null;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        t = tags.tags({});
    });

    afterEach(function () {
        sandbox.restore();
    });


    describe("extensions", function () {
        it("offers a createEditorField function ", function () {
            assert.isFunction(t.createEditorField);
        });

        it("offers a createViewerField function ", function () {
            assert.isFunction(t.createViewerField);
        });
    });

    describe("Editor", function () {
        var elem = null,
            widget = null,
            spy = null,
            input = null;

        beforeEach(function () {
            elem = $("<div><div class='annotator-editor-controls'></div></div>")[0];
            spy = sandbox.spy(editor.Editor.prototype, 'addField');
            widget = new editor.Editor({
                defaultFields: false,
                extensions: [t.createEditorField]
            });
            widget.attach();
            input = $(widget.fields[0].element).find(':input');
        });

        afterEach(function () {
            $(elem).remove();
            widget.destroy();
        });

        it("should stringify a tags array into a space-delimited string", function () {
            var annotation = {
                tags: ['one', 'two', 'three']
            };

            var updateField = spy.getCall(0).args[0].load;
            updateField({}, annotation);
            assert.equal(input.val(), "one two three");
        });

        it("should parse whitespace-delimited tags into an array", function () {
            var str = 'one two  three\tfourFive';
            input.val(str);
            var setAnnotationTags = spy.getCall(0).args[0].submit;
            var annotation = {};
            setAnnotationTags({}, annotation);
            assert.deepEqual(annotation.tags, ['one', 'two', 'three', 'fourFive']);
        });

        describe("updateField", function () {
            it("should set the value of the input", function () {
                var annotation = {
                    tags: ['apples', 'oranges', 'pears']
                };

                var updateField = spy.getCall(0).args[0].load;
                updateField({}, annotation);
                assert.equal(input.val(), 'apples oranges pears');
            });

            it("should set the clear the value of the input if there are no tags", function () {
                var annotation = {};
                input.val('apples pears oranges');
                var updateField = spy.getCall(0).args[0].load;
                updateField({}, annotation);
                assert.equal(input.val(), '');
            });
        });

        describe("setAnnotationTags", function () {
            it("should set the annotation's tags", function () {
                var annotation = {};
                input.val('apples oranges pears');
                var setAnnotationTags = spy.getCall(0).args[0].submit;

                setAnnotationTags({}, annotation);
                assert.deepEqual(annotation.tags, ['apples', 'oranges', 'pears']);
            });
        });
    });

    describe("Viewer", function () {
        var widget = null,
            spy = null;

        beforeEach(function () {
            spy = sandbox.spy(viewer.Viewer.prototype, 'addField');
            widget = new viewer.Viewer({
                defaultFields: false,
                extensions: [t.createViewerField]
            });
            widget.attach();
        });

        afterEach(function () {
            widget.destroy();
        });

        describe("updateViewer", function () {
            it("should insert the tags into the field", function () {
                var annotation = {
                    tags: ['foo', 'bar', 'baz']
                };
                var field = $('<div />')[0];
                var updateViewer = spy.getCall(0).args[0].load;
                updateViewer(field, annotation);
                assert.deepEqual($(field).html(), [
                    '<span class="annotator-tag">foo</span>',
                    '<span class="annotator-tag">bar</span>',
                    '<span class="annotator-tag">baz</span>'
                ].join(' '));
            });

            it("should remove the field if there are no tags", function () {
                var annotation = {
                    tags: []
                };
                var field = $('<div />')[0];

                var updateViewer = spy.getCall(0).args[0].load;
                updateViewer(field, annotation);
                assert.lengthOf($(field).parent(), 0);
                annotation = {};
                field = $('<div />')[0];
                updateViewer(field, annotation);
                assert.lengthOf($(field).parent(), 0);
            });
        });
    });
});
