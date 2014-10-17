var assert = require('assertive-chai').assert;

var Util = require('../../src/util');

describe('Util.escapeHtml()', function () {
    it("escapes tag special characters", function () {
        assert.equal(Util.escapeHtml('/<>'), '&#47;&lt;&gt;');
    });

    it("escapes attribute special characters", function () {
        assert.equal(Util.escapeHtml("'" + '"'), '&#39;&quot;');
    });

    it("escapes entity special characters", function () {
        assert.equal(Util.escapeHtml('&'), '&amp;');
    });

    it("escapes entity special characters strictly", function () {
        assert.equal(Util.escapeHtml('&amp;'), '&amp;amp;');
    });
});
