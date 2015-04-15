var assert = require('assertive-chai').assert;

var authz = require('../../src/authz');


describe('authz.defaultAuthorizationPolicy', function () {
    var p = authz.defaultAuthorizationPolicy;

    describe('.permits(...)', function () {
        it('permits any action for an annotation with no authorisation info', function () {
            assert.isTrue(p.permits('foo', {}, null));
            assert.isTrue(p.permits('foo', {}, 'alice'));
        });

        it('refuses any action if an annotation has a user and no identity is set', function () {
            assert.isFalse(p.permits('foo', {user: 'alice'}, null));
        });

        it('permits any action if annotation has a user which matches the identity', function () {
            assert.isTrue(p.permits('foo', {user: 'alice'}, 'alice'));
        });

        it('refuses any action if annotation has a user which does not match the identity', function () {
            assert.isFalse(p.permits('foo', {user: 'alice'}, 'bob'));
        });

        it('permits any action if annotation.permissions[action] is undefined or null', function () {
            var a = {permissions: {}};
            assert.isTrue(p.permits('foo', a, null));
            assert.isTrue(p.permits('foo', a, 'alice'));
        });

        it('refuses an action if annotation.permissions[action] == []', function () {
            var a = {permissions: {'foo': []}};
            assert.isFalse(p.permits('foo', a, null));
            assert.isFalse(p.permits('foo', a, 'bob'));
        });

        it('permits an action if annotation.permissions[action] contains >0 tokens which match the identity', function () {
            var a = {permissions: {'foo': ['alice']}};
            assert.isTrue(p.permits('foo', a, 'alice'));
        });
    });
});
