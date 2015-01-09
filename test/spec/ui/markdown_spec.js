var assert = require('assertive-chai').assert;

var UI = require('../../../src/ui'),
    Util = require('../../../src/util');

var g = Util.getGlobal();

describe('UI.markdown', function () {
    var plugin = null;

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
        var escapeHtml = null;
        var makeHtml = null;

        beforeEach(function () {
            escapeHtml = sinon.stub(Util, 'escapeHtml').returns('escaped');
            makeHtml = sinon.stub().returns('converted');

            var fakeShowDown = {
                converter: function () {
                    return {
                        makeHtml: makeHtml
                    };
                }
            };

            showdown = g.Showdown;
            g.Showdown = fakeShowDown;
        });

        afterEach(function () {
            Util.escapeHtml.restore();
            g.Showdown = showdown;
        });

        it("should escape and convert the provided text into markdown", function () {
            plugin = UI.markdown();
            assert.equal(plugin.convert('foo'), 'converted');
            assert.isTrue(escapeHtml.calledWith('foo'));
            assert.isTrue(makeHtml.calledWith('escaped'));
        });

        it("should escape even if showdown is not loaded", function () {
            g.Showdown = null;
            plugin = UI.markdown();
            assert.equal(plugin.convert('foo'), 'escaped');
        });
    });
});
