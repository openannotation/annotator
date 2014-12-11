var assert = require('assertive-chai').assert;

var Annotator = require('annotator'),
    Markdown = require('../../../src/plugin/markdown');

var $ = Annotator.Util.$;

describe('Markdown plugin', function () {
    var input = 'Is **this** [Markdown](http://daringfireball.com)?',
        output = '<p>Is <strong>this</strong> <a href="http://daringfireball.com">Markdown</a>?</p>',
        annotator = null,
        plugin = null;

    beforeEach(function () {
        plugin = new Markdown($('<div/>')[0]);
        sinon.spy(Markdown.prototype, 'updateTextField');
        plugin.pluginInit();
    });

    afterEach(function () {
        Markdown.prototype.updateTextField.restore();
        plugin.destroy();
    });

    describe("#updateTextField()", function () {
        it("should be called when annotationViewerTextField event is fired", function () {
            var field = $('<div />')[0];
            var annotation = {
                text: 'test'
            };
            annotator.trigger('annotationViewerTextField', field, annotation);
            assert.isTrue(plugin.updateTextField.calledWith(field, annotation));
        });
    });

    describe("constructor", function () {
        it("should create a new instance of Showdown", function () {
            assert.ok(plugin.converter);
        });

        it("should log an error if Showdown is not loaded", function () {
            sinon.stub(console, 'error');
            var converter = Showdown.converter;
            Showdown.converter = null;
            plugin = new Markdown($('<div />')[0]);
            assert(console.error.calledOnce);
            Showdown.converter = converter;
            console.error.restore();
        });
    });

    describe("updateTextField", function () {
        var field = null,
            annotation = null;

        beforeEach(function () {
            field = $('<div />')[0];
            annotation = {
                text: input
            };
            sinon.stub(plugin, 'convert').returns(output);
            sinon.stub(Annotator.Util, 'escapeHtml').returns(input);
            plugin.updateTextField(field, annotation);
        });

        afterEach(function () {
            Annotator.Util.escapeHtml.restore();
        });

        it('should process the annotation text as Markdown', function () {
            assert.isTrue(plugin.convert.calledWith(input));
        });

        it('should update the content in the field', function () {
            // In IE, tags might be converted into all uppercase,
            // so we need to normalise those.
            assert.equal($(field).html().toLowerCase(), output.toLowerCase());
            // But also make sure the text is exactly the same.
            assert.equal($(field).text(), $(output).text());
        });

        it("should escape any existing HTML to prevent XSS", function () {
            assert.isTrue(Annotator.Util.escapeHtml.calledWith(input));
        });
    });

    describe("convert", function () {
        it("should convert the provided text into markdown", function () {
            assert.equal(plugin.convert(input), output);
        });
    });
});
