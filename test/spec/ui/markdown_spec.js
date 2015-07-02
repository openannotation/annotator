var assert = require('assertive-chai').assert;

var markdown = require('../../../src/ui/markdown'),
    util = require('../../../src/util');

describe('ui.markdown.render', function () {
    var sandbox;
    var makeHtml;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        sandbox.stub(util, 'escapeHtml').returns('escaped');
        makeHtml = sandbox.stub().returns('converted');

        global.showdown = {
            Converter: function () {
                return {makeHtml: makeHtml};
            }
        };
    });

    afterEach(function () {
        sandbox.restore();
    });

    it("should convert annotation text", function () {
        assert.equal('converted', markdown.render({text: 'wibble'}));

        sinon.assert.calledWith(makeHtml, 'wibble');
    });

    it("should handle annotations without text", function () {
        assert.equal('<i>No comment</i>', markdown.render({}));
    });

    it("should HTML escape text if Showdown is not available", function () {
        global.showdown = null;

        assert.equal('escaped', markdown.render({text: 'foo'}));
        sinon.assert.calledWith(util.escapeHtml, 'foo');
    });
});


describe('ui.markdown.viewerExtension', function () {
    var sandbox;
    var mockViewer;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        mockViewer = {
            setRenderer: sandbox.stub()
        };
        global.showdown = {
            Converter: function () {
                return {makeHtml: sandbox.stub()};
            }
        };
    });

    afterEach(function () {
        sandbox.restore();
    });

    it("should log a warning if Showdown is not present in the page", function () {
        sandbox.stub(console, 'warn');
        global.showdown = null;

        markdown.viewerExtension(mockViewer);

        assert(console.warn.calledOnce);
    });

    it("sets the viewer renderer to the markdown render function", function () {
        markdown.viewerExtension(mockViewer);

        sinon.assert.calledWith(mockViewer.setRenderer, markdown.render);
    });
});
