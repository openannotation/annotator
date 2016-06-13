var assert = require('assertive-chai').assert;

var identity = require('../../src/identity');


describe('identity.SimpleIdentityPolicy', function () {
    var ident;

    beforeEach(function () {
        ident = new identity.SimpleIdentityPolicy();
    });

    describe('.who()', function () {
        it('returns null', function () {
            assert.isNull(ident.who());
        });

        it('returns .identity if set', function () {
            ident.identity = 'alice';
            assert.equal('alice', ident.who());
        });
    });
});
