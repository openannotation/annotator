var assert = require('assertive-chai').assert;

var authz = require('../../src/authz');


describe('authz.AclAuthzPolicy', function () {
    var p;

    beforeEach(function () {
        p = new authz.AclAuthzPolicy();
    });

    describe('.permits(...)', function () {
        it('permits any action if there is no permission info', function () {
            assert.isTrue(p.permits('foo', {}, null));
            assert.isTrue(p.permits('foo', {}, 'alice'));
        });

        it('refuses any action if an context has a user and no identity is set', function () {
            assert.isFalse(p.permits('foo', {user: 'alice'}, null));
        });

        it('permits any action if context has a user which matches the identity', function () {
            assert.isTrue(p.permits('foo', {user: 'alice'}, 'alice'));
        });

        it('refuses any action if context has a user which does not match the identity', function () {
            assert.isFalse(p.permits('foo', {user: 'alice'}, 'bob'));
        });

        it('permits any action if permissions are undefined or null', function () {
            var a = {permissions: {}};
            assert.isTrue(p.permits('foo', a, null));
            assert.isTrue(p.permits('foo', a, 'alice'));
        });

        it('refuses an action if permissions[action] == []', function () {
            var a = {permissions: {'foo': []}};
            assert.isFalse(p.permits('foo', a, null));
            assert.isFalse(p.permits('foo', a, 'bob'));
        });

        it('permits an action if permissions[action] contains >0 tokens which match the identity', function () {
            var a = {permissions: {'foo': ['alice']}};
            assert.isTrue(p.permits('foo', a, 'alice'));
        });
    });
});
