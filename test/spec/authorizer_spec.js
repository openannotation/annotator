var assert = require('assertive-chai').assert;

var authorizer = require('../../src/authorizer');


describe('authorizer.Default', function () {
    var authz;

    beforeEach(function () {
        authz = authorizer.Default()();
    });

    describe('#permits(...)', function () {
        it('permits any action for an annotation with no authorisation info', function () {
            assert.isTrue(authz.permits('foo', {}, null));
            assert.isTrue(authz.permits('foo', {}, 'alice'));
        });

        it('refuses any action if an annotation has a user and no identity is set', function () {
            assert.isFalse(authz.permits('foo', {user: 'alice'}, null));
        });

        it('permits any action if annotation has a user which matches the identity', function () {
            assert.isTrue(authz.permits('foo', {user: 'alice'}, 'alice'));
        });

        it('permits any action if annotation has a user which matches the identity (with a custom userId function)', function () {
            var customAuthorizer = authorizer.Default({
                userId: function (u) { return u.id; }
            })();
            assert.isTrue(customAuthorizer.permits(
                'foo',
                {user: 'bob'},
                {id: 'bob'}
            ));
        });

        it('refuses any action if annotation has a user which does not match the identity', function () {
            assert.isFalse(authz.permits('foo', {user: 'alice'}, 'bob'));
        });

        it('refuses any action if annotation has a user which does not match the identity (with a custom userId function)', function () {
            var customAuthorizer = authorizer.Default({
                userId: function (u) { return u.id; }
            })();
            assert.isFalse(customAuthorizer.permits(
                'foo',
                {user: 'alice'},
                {id: 'bob'}
            ));
        });

        it('permits any action if annotation.permissions[action] is undefined or null', function () {
            var a = {permissions: {}};
            assert.isTrue(authz.permits('foo', a, null));
            assert.isTrue(authz.permits('foo', a, 'alice'));
        });

        it('refuses an action if annotation.permissions[action] == []', function () {
            var a = {permissions: {'foo': []}};
            assert.isFalse(authz.permits('foo', a, null));
            assert.isFalse(authz.permits('foo', a, 'bob'));
        });

        it('permits an action if annotation.permissions[action] contains >0 tokens which match the identity', function () {
            var a = {permissions: {'foo': ['alice']}};
            assert.isTrue(authz.permits('foo', a, 'alice'));
        });

        it('permits an action if annotation.permissions[action] contains >0 tokens which match the identity (with a custom userId function)', function () {
            var a = {permissions: {'foo': ['alice']}},
                customAuthorizer = authorizer.Default({
                    userId: function (u) { return u.id; }
                })();
            assert.isTrue(customAuthorizer.permits('foo', a, {id: 'alice'}));
        });
    });
});
