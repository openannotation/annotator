var assert = require('assertive-chai').assert;

var ui = require('../../../src/ui'),
    util = require('../../../src/util');

var g = util.getGlobal();

describe('ui.markdown', function () {
    var plugin = null;

    describe("constructor", function () {
        it("should log warning if Showdown is not loaded", function () {
            sinon.stub(console, 'warn');
            var showdown = g.Showdown;
            g.Showdown = null;
            plugin = ui.markdown();
            assert(console.warn.calledOnce);
            console.warn.restore();
            g.Showdown = showdown;
        });
    });

    describe("convert", function () {
        var showdown = null;
        var escapeHtml = null;
        var makeHtml = null;

        beforeEach(function () {
            escapeHtml = sinon.stub(util, 'escapeHtml').returns('escaped');
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
            util.escapeHtml.restore();
            g.Showdown = showdown;
        });

        it("should escape and convert the provided text into markdown", function () {
            plugin = ui.markdown();
            assert.equal(plugin.convert('foo'), 'converted');
            assert.isTrue(escapeHtml.calledWith('foo'));
            assert.isTrue(makeHtml.calledWith('escaped'));
        });

        it("should escape even if showdown is not loaded", function () {
            sinon.stub(console, 'warn');
            g.Showdown = null;
            plugin = ui.markdown();
            assert.equal(plugin.convert('foo'), 'escaped');
        });
    });
});
