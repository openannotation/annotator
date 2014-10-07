var $, Annotator, Markdown;

Annotator = require('annotator');

Markdown = require('../../../src/plugin/markdown');

$ = Annotator.Util.$;

describe('Markdown plugin', function() {
    var annotator, input, output, plugin;
    input = 'Is **this** [Markdown](http://daringfireball.com)?';
    output = '<p>Is <strong>this</strong> <a href="http://daringfireball.com">Markdown</a>?</p>';
    annotator = null;
    plugin = null;
    beforeEach(function() {
        plugin = new Markdown($('<div/>')[0]);
        sinon.spy(Markdown.prototype, 'updateTextField');
        return plugin.pluginInit();
    });
    afterEach(function() {
        Markdown.prototype.updateTextField.restore();
        return plugin.destroy();
    });
    describe("#updateTextField()", function() {
        return it("should be called when annotationViewerTextField event is fired", function() {
            var annotation, field;
            field = $('<div />')[0];
            annotation = {
                text: 'test'
            };
            annotator.trigger('annotationViewerTextField', field, annotation);
            return assert.isTrue(plugin.updateTextField.calledWith(field, annotation));
        });
    });
    describe("constructor", function() {
        it("should create a new instance of Showdown", function() {
            return assert.ok(plugin.converter);
        });
        return it("should log an error if Showdown is not loaded", function() {
            var converter;
            sinon.stub(console, 'error');
            converter = Showdown.converter;
            Showdown.converter = null;
            plugin = new Markdown($('<div />')[0]);
            assert(console.error.calledOnce);
            Showdown.converter = converter;
            return console.error.restore();
        });
    });
    describe("updateTextField", function() {
        var annotation, field;
        field = null;
        annotation = null;
        beforeEach(function() {
            field = $('<div />')[0];
            annotation = {
                text: input
            };
            sinon.stub(plugin, 'convert').returns(output);
            sinon.stub(Annotator.Util, 'escapeHtml').returns(input);
            return plugin.updateTextField(field, annotation);
        });
        afterEach(function() {
            return Annotator.Util.escapeHtml.restore();
        });
        it('should process the annotation text as Markdown', function() {
            return assert.isTrue(plugin.convert.calledWith(input));
        });
        it('should update the content in the field', function() {
            // In IE, tags might be converted into all uppercase,
            // so we need to normalise those.
            assert.equal($(field).html().toLowerCase(), output.toLowerCase());
            // But also make sure the text is exactly the same.
            return assert.equal($(field).text(), $(output).text());
        });
        return it("should escape any existing HTML to prevent XSS", function() {
            return assert.isTrue(Annotator.Util.escapeHtml.calledWith(input));
        });
    });
    return describe("convert", function() {
        return it("should convert the provided text into markdown", function() {
            return assert.equal(plugin.convert(input), output);
        });
    });
});
