var assert = require('assertive-chai').assert;

var registry = require('../../src/registry');

describe('Registry', function () {
    var r;

    beforeEach(function () {
        r = new registry.Registry();
    });

    it('registerUtility registers a object as a named utility', function () {
        var o = {};
        r.registerUtility(o, 'foo');
        assert.strictEqual(o, r.getUtility('foo'));
    });

    it('getUtility returns the most recently registered object', function () {
        var o = {}, p = {};
        r.registerUtility(o, 'foo');
        r.registerUtility(p, 'foo');
        assert.strictEqual(p, r.getUtility('foo'));
    });

    it('getUtility throws LookupError if no utility is registered', function () {
        var fn = function () { r.getUtility('foo'); };
        assert.throws(fn, registry.LookupError);
    });

    it('queryUtility returns null if no utility is registered', function () {
        var res = r.queryUtility('foo');
        assert.isNull(res);
    });
});
