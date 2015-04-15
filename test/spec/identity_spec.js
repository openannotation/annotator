var assert = require('assertive-chai').assert;

var identity = require('../../src/identity');


describe('identity.defaultIdentityPolicy', function () {
    describe('.who()', function () {
        it('returns null', function () {
            assert.isNull(identity.defaultIdentityPolicy.who());
        });

        it('returns .identity if set', function () {
            identity.defaultIdentityPolicy.identity = 'alice';
            assert.equal('alice', identity.defaultIdentityPolicy.who());
        });
    });
});
