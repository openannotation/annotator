var Annotator = require('annotator'),
    Tags = require('../../../src/plugin/tags');

var $ = Annotator.Util.$;

describe('Tags plugin', function () {
    var el = null,
        annotator = null,
        plugin = null;

    beforeEach(function () {
        el = $("<div><div class='annotator-editor-controls'></div></div>")[0];
        annotator = new Annotator($('<div/>')[0]);
        plugin = new Tags(el);
        plugin.annotator = annotator;
        plugin.pluginInit();
    });

    afterEach(function () {
        annotator.destroy();
        if (typeof plugin.destroy === "function") {
            plugin.destroy();
        }
        $(el).remove();
    });

    it("should parse whitespace-delimited tags into an array", function () {
        var str = 'one two  three\tfourFive';
        assert.deepEqual(plugin.parseTags(str), ['one', 'two', 'three', 'fourFive']);
    });

    it("should stringify a tags array into a space-delimited string", function () {
        var ary = ['one', 'two', 'three'];
        assert.equal(plugin.stringifyTags(ary), "one two three");
    });

    describe("pluginInit", function () {
        it("should add a field to the editor", function () {
            sinon.spy(annotator.editor, 'addField');
            plugin.pluginInit();
            assert(annotator.editor.addField.calledOnce);
        });

        it("should register a filter if the Filter plugin is loaded", function () {
            plugin.annotator.plugins.Filter = {
                addFilter: sinon.spy()
            };
            plugin.pluginInit();
            assert(plugin.annotator.plugins.Filter.addFilter.calledOnce);
        });
    });

    describe("updateField", function () {
        it("should set the value of the input", function () {
            var annotation = {
                tags: ['apples', 'oranges', 'pears']
            };
            plugin.updateField(plugin.field, annotation);
            assert.equal(plugin.input.val(), 'apples oranges pears');
        });

        it("should set the clear the value of the input if there are no tags", function () {
            var annotation = {};
            plugin.input.val('apples pears oranges');
            plugin.updateField(plugin.field, annotation);
            assert.equal(plugin.input.val(), '');
        });
    });

    describe("setAnnotationTags", function () {
        it("should set the annotation's tags", function () {
            var annotation = {};
            plugin.input.val('apples oranges pears');
            plugin.setAnnotationTags(plugin.field, annotation);
            assert.deepEqual(annotation.tags, ['apples', 'oranges', 'pears']);
        });
    });

    describe("updateViewer", function () {
        it("should insert the tags into the field", function () {
            var annotation = {
                tags: ['foo', 'bar', 'baz']
            };
            var field = $('<div />')[0];
            plugin.updateViewer(field, annotation);
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
            plugin.updateViewer(field, annotation);
            assert.lengthOf($(field).parent(), 0);
            annotation = {};
            field = $('<div />')[0];
            plugin.updateViewer(field, annotation);
            assert.lengthOf($(field).parent(), 0);
        });
    });
});

describe('Tags plugin filterCallback', function () {
    var filter = null;

    beforeEach(function () {
        filter = Tags.filterCallback;
    });

    it('should return true if all tags are matched by keywords', function () {
        assert.isTrue(filter('cat dog mouse', ['cat', 'dog', 'mouse']));
        assert.isTrue(filter('cat dog', ['cat', 'dog', 'mouse']));
    });

    it('should NOT return true if all tags are NOT matched by keywords', function () {
        assert.isFalse(filter('cat dog', ['cat']));
        assert.isFalse(filter('cat dog', []));
    });
});
