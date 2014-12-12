var assert = require('assertive-chai').assert;

var UI = require('../../../src/ui'),
    Util = require('../../../src/util');

var $ = Util.$;

describe('UI.Tags', function () {
    var tags = null,
        sandbox = null;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        tags = UI.tags({});
    });

    afterEach(function () {
        sandbox.restore();
    });


    describe("extensions", function () {
        it("offers a createEditorField function ", function () {
            assert.isFunction(tags.createEditorField);
        });

        it("offers a createViewerField function ", function () {
            assert.isFunction(tags.createViewerField);
        });
    });

    describe("Editor", function () {
        var elem = null,
            editor = null,
            spy = null,
            input = null;

        beforeEach(function () {
            elem = $("<div><div class='annotator-editor-controls'></div></div>")[0];
            spy = sandbox.spy(UI.Editor.prototype, 'addField');
            editor = new UI.Editor({
                defaultFields: false,
                extensions: [tags.createEditorField]
            });
            editor.attach();
            input = $(editor.fields[0].element).find(':input');
        });

        afterEach(function () {
            $(elem).remove();
            editor.destroy();
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
        var viewer = null,
            spy = null;

        beforeEach(function () {
            spy = sandbox.spy(UI.Viewer.prototype, 'addField');
            viewer = new UI.Viewer({
                defaultFields: false,
                extensions: [tags.createViewerField]
            });
            viewer.attach();
        });

        afterEach(function () {
            viewer.destroy();
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
