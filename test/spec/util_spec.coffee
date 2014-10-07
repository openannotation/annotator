var $, Util, h;

h = require('helpers');

Util = require('../../src/util');

$ = Util.$;

describe('Util.escapeHtml()', function() {
    it("escapes tag special characters", function() {
        return assert.equal(Util.escapeHtml('/<>'), '&#47;&lt;&gt;');
    });
    it("escapes attribute special characters", function() {
        return assert.equal(Util.escapeHtml("'" + '"'), '&#39;&quot;');
    });
    it("escapes entity special characters", function() {
        return assert.equal(Util.escapeHtml('&'), '&amp;');
    });
    return it("escapes entity special characters strictly", function() {
        return assert.equal(Util.escapeHtml('&amp;'), '&amp;amp;');
    });
});
