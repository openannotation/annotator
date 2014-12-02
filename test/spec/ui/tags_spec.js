var assert = require('assertive-chai').assert;

var UI = require('../../../src/ui'),
    Editor = require('../../../src/ui/editor'),
    Util = require('../../../src/util');

var $ = Util.$;

describe('UI.Tags', function () {
    var elem = null,
        tags = null,
        editor = null;

    beforeEach(function () {
        elem = $("<div><div class='annotator-editor-controls'></div></div>")[0];
        tags = new UI.Tags(elem);
        editor = new Editor.Editor({
            extensions: [tags.configureEditor]
        });
    });

    afterEach(function () {
        $(elem).remove();
        editor.destroy();
    });

    it("should parse whitespace-delimited tags into an array", function () {
        var str = 'one two  three\tfourFive';
        assert.deepEqual(tags.parseTags(str), ['one', 'two', 'three', 'fourFive']);
    });

    it("should stringify a tags array into a space-delimited string", function () {
        var ary = ['one', 'two', 'three'];
        assert.equal(tags.stringifyTags(ary), "one two three");
    });

    describe("extensions", function () {
        it("offers a configureEditor function ", function () {
            assert.isFunction(tags.configureEditor);
        });

        it("offers a configureViewer function ", function () {
            assert.isFunction(tags.configureViewer);
        });
    });

    describe("updateField", function () {
        it("should set the value of the input", function () {
            var annotation = {
                tags: ['apples', 'oranges', 'pears']
            };
            tags.updateField(tags.field, annotation);
            assert.equal(tags.input.val(), 'apples oranges pears');
        });

        it("should set the clear the value of the input if there are no tags", function () {
            var annotation = {};
            tags.input.val('apples pears oranges');
            tags.updateField(tags.field, annotation);
            assert.equal(tags.input.val(), '');
        });
    });

    describe("setAnnotationTags", function () {
        it("should set the annotation's tags", function () {
            var annotation = {};
            tags.input.val('apples oranges pears');
            tags.setAnnotationTags(tags.field, annotation);
            assert.deepEqual(annotation.tags, ['apples', 'oranges', 'pears']);
        });
    });

    describe("updateViewer", function () {
        it("should insert the tags into the field", function () {
            var annotation = {
                tags: ['foo', 'bar', 'baz']
            };
            var field = $('<div />')[0];
            tags.updateViewer(field, annotation);
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
            tags.updateViewer(field, annotation);
            assert.lengthOf($(field).parent(), 0);
            annotation = {};
            field = $('<div />')[0];
            tags.updateViewer(field, annotation);
            assert.lengthOf($(field).parent(), 0);
        });
    });
});
