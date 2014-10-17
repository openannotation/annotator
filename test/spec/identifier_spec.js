var assert = require('assertive-chai').assert;

var Identifier = require('../../src/identifier');


describe('Identifier.Default', function () {
    describe('#who()', function () {
        it('returns the identity passed to the factory', function () {
            var identifier = Identifier.Default('alice')();
            assert.equal(identifier.who(), 'alice');
        });
    });
});
