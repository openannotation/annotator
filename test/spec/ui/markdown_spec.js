var assert = require('assertive-chai').assert;

var UI = require('../../../src/ui'),
    Util = require('../../../src/util');

var g = Util.getGlobal();

describe('UI.markdown', function () {
    var input = 'Is **this** [Markdown](http://daringfireball.com)?',
        output = '<p>Is <strong>this</strong> <a href="http://daringfireball.com">Markdown</a>?</p>',
        plugin = null;

    afterEach(function () {
    });

    describe("constructor", function () {
        it("should log an error if Showdown is not loaded", function () {
            sinon.stub(console, 'error');
            var showdown = g.Showdown;
            g.Showdown = null;
            plugin = UI.markdown();
            assert(console.error.calledOnce);
            console.error.restore();
            g.Showdown = showdown;
        });
    });

    describe("convert", function () {
        var showdown = null;

        beforeEach(function () {
            sinon.stub(Util, 'escapeHtml').returns(input);

            var fakeShowDown = {
                converter: function () {
                    return {
                        makeHtml: function () {
                            return output;
                        }
                    };
                }
            };

            showdown = g.Showdown;
            g.Showdown = fakeShowDown;

            plugin = UI.markdown();
            sinon.spy(plugin, 'convert');
        });

        afterEach(function () {
            Util.escapeHtml.restore();
            g.Showdown = showdown;
        });

        it("should escape any existing HTML to prevent XSS", function () {
            plugin.convert(input);
            assert.isTrue(Util.escapeHtml.calledWith(input));
        });

        it("should convert the provided text into markdown", function () {
            assert.equal(plugin.convert(input), output);
        });
    });
});
