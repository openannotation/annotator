var Identifier = require('../../src/identifier');


describe('Identifier.Default', function () {
    describe('#who()', function () {
        it('returns the identity passed to the constructor', function () {
            var identifier = Identifier.Default('alice')();
            assert.equal(identifier.who(), 'alice');
        });
    });
});
