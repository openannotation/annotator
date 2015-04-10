var assert = require('assertive-chai').assert;

var identifier = require('../../src/identifier');


describe('identifier.Default', function () {
    describe('#who()', function () {
        it('returns the identity passed to the factory', function () {
            var ident = identifier.Default('alice')();
            assert.equal(ident.who(), 'alice');
        });
    });
});
