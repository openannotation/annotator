var assert = require('assertive-chai').assert;

var annotator = require('../../src/annotator');

describe("supported()", function () {
    var scope = null;

    beforeEach(function () {
        scope = {
            getSelection: function () {},
            JSON: window.JSON
        };
    });

    it("returns true if all is well", function () {
        assert.isTrue(annotator.supported(null, scope));
    });

    it("returns false if scope has no getSelection function", function () {
        delete scope.getSelection;
        assert.isFalse(annotator.supported(null, scope));
    });

    it("returns false if scope has no JSON object", function () {
        delete scope.JSON;
        assert.isFalse(annotator.supported(null, scope));
    });

    it("returns false if scope JSON object has no stringify function", function () {
        scope.JSON = {
            parse: function () {}
        };
        assert.isFalse(annotator.supported(null, scope));
    });

    it("returns false if scope JSON object has no parse function", function () {
        scope.JSON = {
            stringify: function () {}
        };
        assert.isFalse(annotator.supported(null, scope));
    });

    it("returns extra details if details is true and all is well", function () {
        var res;
        res = annotator.supported(true, scope);
        assert.isTrue(res.supported);
        assert.deepEqual(res.errors, []);
    });

    it("returns extra details if details is true and everything is broken", function () {
        var res;
        res = annotator.supported(true, {});
        assert.isFalse(res.supported);
        assert.equal(res.errors.length, 2);
    });
});
