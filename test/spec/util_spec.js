var assert = require('assertive-chai').assert;

var util = require('../../src/util');

describe('util.escapeHtml()', function () {
    it("escapes tag special characters", function () {
        assert.equal(util.escapeHtml('/<>'), '&#47;&lt;&gt;');
    });

    it("escapes attribute special characters", function () {
        assert.equal(util.escapeHtml("'" + '"'), '&#39;&quot;');
    });

    it("escapes entity special characters", function () {
        assert.equal(util.escapeHtml('&'), '&amp;');
    });

    it("escapes entity special characters strictly", function () {
        assert.equal(util.escapeHtml('&amp;'), '&amp;amp;');
    });
});
