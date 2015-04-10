var assert = require('assertive-chai').assert;

var annotator = require('../../browser');

describe("noConflict()", function () {
    var _annotator = null;

    beforeEach(function () {
        _annotator = annotator;
    });

    afterEach(function () {
        window.annotator = _annotator;
    });

    it("should restore the value previously occupied by window.annotator", function () {
        annotator.noConflict();
        assert.isUndefined(window.annotator);
    });

    it("should return the annotator object", function () {
        var result = annotator.noConflict();
        assert.equal(result, _annotator);
    });
});

