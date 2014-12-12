var assert = require('assertive-chai').assert;

var Annotator = require('annotator');

describe("Annotator.noConflict()", function () {
    var _Annotator = null;

    beforeEach(function () {
        _Annotator = Annotator;
    });

    afterEach(function () {
        window.Annotator = _Annotator;
    });

    it("should restore the value previously occupied by window.Annotator", function () {
        Annotator.noConflict();
        assert.isUndefined(window.Annotator);
    });

    it("should return the Annotator object", function () {
        var result;
        result = Annotator.noConflict();
        assert.equal(result, _Annotator);
    });
});

describe("Annotator.supported()", function () {
    var scope = null;

    beforeEach(function () {
        scope = {
            getSelection: function () {},
            JSON: JSON
        };
    });

    it("returns true if all is well", function () {
        assert.isTrue(Annotator.supported(null, scope));
    });

    it("returns false if scope has no getSelection function", function () {
        delete scope.getSelection;
        assert.isFalse(Annotator.supported(null, scope));
    });

    it("returns false if scope has no JSON object", function () {
        delete scope.JSON;
        assert.isFalse(Annotator.supported(null, scope));
    });

    it("returns false if scope JSON object has no stringify function", function () {
        scope.JSON = {
            parse: function () {}
        };
        assert.isFalse(Annotator.supported(null, scope));
    });

    it("returns false if scope JSON object has no parse function", function () {
        scope.JSON = {
            stringify: function () {}
        };
        assert.isFalse(Annotator.supported(null, scope));
    });

    it("returns extra details if details is true and all is well", function () {
        var res;
        res = Annotator.supported(true, scope);
        assert.isTrue(res.supported);
        assert.deepEqual(res.errors, []);
    });

    it("returns extra details if details is true and everything is broken", function () {
        var res;
        res = Annotator.supported(true, {});
        assert.isFalse(res.supported);
        assert.equal(res.errors.length, 2);
    });
});
