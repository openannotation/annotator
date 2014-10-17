var assert = require('assertive-chai').assert;

var Authorizer = require('../../src/authorizer');


describe('Authorizer.Default', function () {
    var authorizer;

    beforeEach(function () {
        authorizer = Authorizer.Default()();
    });

    describe('#permits(...)', function () {
        it('permits any action for an annotation with no authorisation info', function () {
            assert.isTrue(authorizer.permits('foo', {}, null));
            assert.isTrue(authorizer.permits('foo', {}, 'alice'));
        });

        it('refuses any action if an annotation has a user and no identity is set', function () {
            assert.isFalse(authorizer.permits('foo', {user: 'alice'}, null));
        });

        it('permits any action if annotation has a user which matches the identity', function () {
            assert.isTrue(authorizer.permits('foo', {user: 'alice'}, 'alice'));
        });

        it('permits any action if annotation has a user which matches the identity (with a custom userId function)', function () {
            var customAuthorizer = Authorizer.Default({
                userId: function (u) { return u.id; }
            })();
            assert.isTrue(customAuthorizer.permits(
                'foo',
                {user: 'bob'},
                {id: 'bob'}
            ));
        });

        it('refuses any action if annotation has a user which does not match the identity', function () {
            assert.isFalse(authorizer.permits('foo', {user: 'alice'}, 'bob'));
        });

        it('refuses any action if annotation has a user which does not match the identity (with a custom userId function)', function () {
            var customAuthorizer = Authorizer.Default({
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
            assert.isTrue(authorizer.permits('foo', a, null));
            assert.isTrue(authorizer.permits('foo', a, 'alice'));
        });

        it('refuses an action if annotation.permissions[action] == []', function () {
            var a = {permissions: {'foo': []}};
            assert.isFalse(authorizer.permits('foo', a, null));
            assert.isFalse(authorizer.permits('foo', a, 'bob'));
        });

        it('permits an action if annotation.permissions[action] contains >0 tokens which match the identity', function () {
            var a = {permissions: {'foo': ['alice']}};
            assert.isTrue(authorizer.permits('foo', a, 'alice'));
        });

        it('permits an action if annotation.permissions[action] contains >0 tokens which match the identity (with a custom userId function)', function () {
            var a = {permissions: {'foo': ['alice']}},
                customAuthorizer = Authorizer.Default({
                    userId: function (u) { return u.id; }
                })();
            assert.isTrue(customAuthorizer.permits('foo', a, {id: 'alice'}));
        });
    });
});
