var assert = require('assertive-chai').assert;

var markdown = require('../../../src/ui/markdown'),
    util = require('../../../src/util');

var g = util.getGlobal();

describe('ui.markdown.renderer', function () {
    var sandbox;
    var makeHtml;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        sandbox.stub(util, 'escapeHtml').returns('escaped');
        makeHtml = sandbox.stub().returns('converted');

        g.Showdown = {
            converter: function () {
                return {makeHtml: makeHtml};
            }
        };
    });

    afterEach(function () {
        sandbox.restore();
    });

    it("should log a warning if Showdown is not present in the page", function () {
        sandbox.stub(console, 'warn');
        g.Showdown = null;

        markdown.renderer({});

        assert(console.warn.calledOnce);
    });

    it("returned function should convert annotation text", function () {
        assert.equal('converted', markdown.renderer({text: 'wibble'}));

        sinon.assert.calledWith(makeHtml, 'wibble');
    });

    it("returned function should handle annotations without text", function () {
        assert.equal('<i>No comment</i>', markdown.renderer({}));
    });

    it("returned function should HTML escape text if Showdown is not available", function () {
        sinon.stub(console, 'warn');
        g.Showdown = null;

        assert.equal('escaped', markdown.renderer({text: 'foo'}));
        sinon.assert.calledWith(util.escapeHtml, 'foo');
    });
});
