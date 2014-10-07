var Annotator;

Annotator = require('annotator');

describe("Annotator.noConflict()", function() {
    var _Annotator;
    _Annotator = null;
    beforeEach(function() {
        return _Annotator = Annotator;
    });
    afterEach(function() {
        return window.Annotator = _Annotator;
    });
    it("should restore the value previously occupied by window.Annotator", function() {
        Annotator.noConflict();
        return assert.isUndefined(window.Annotator);
    });
    return it("should return the Annotator object", function() {
        var result;
        result = Annotator.noConflict();
        return assert.equal(result, _Annotator);
    });
});

describe("Annotator.supported()", function() {
    var scope;
    scope = null;
    beforeEach(function() {
        return scope = {
            getSelection: function() {},
            JSON: JSON
        };
    });
    it("returns true if all is well", function() {
        return assert.isTrue(Annotator.supported(null, scope));
    });
    it("returns false if scope has no getSelection function", function() {
        delete scope.getSelection;
        return assert.isFalse(Annotator.supported(null, scope));
    });
    it("returns false if scope has no JSON object", function() {
        delete scope.JSON;
        return assert.isFalse(Annotator.supported(null, scope));
    });
    it("returns false if scope JSON object has no stringify function", function() {
        scope.JSON = {
            parse: function() {}
        };
        return assert.isFalse(Annotator.supported(null, scope));
    });
    it("returns false if scope JSON object has no parse function", function() {
        scope.JSON = {
            stringify: function() {}
        };
        return assert.isFalse(Annotator.supported(null, scope));
    });
    it("returns extra details if details is true and all is well", function() {
        var res;
        res = Annotator.supported(true, scope);
        assert.isTrue(res.supported);
        return assert.deepEqual(res.errors, []);
    });
    return it("returns extra details if details is true and everything is broken", function() {
        var res;
        res = Annotator.supported(true, {});
        assert.isFalse(res.supported);
        return assert.equal(res.errors.length, 2);
    });
});
