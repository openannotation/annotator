var assert = require('assertive-chai').assert;

var identity = require('../../src/identity');


describe('identity.simple', function () {
    var ext;

    beforeEach(function () {
        ext = new identity.simple();
    });

    describe('configure hook', function () {
        it('registers an identity policy', function () {
            var policy = {
                identity: sinon.match.any,
                who: sinon.match.func
            };
            var register = sinon.stub();
            ext.configure({registerUtility: register});
            sinon.assert.calledOnce(register);
            sinon.assert.calledWithMatch(register, policy, 'identityPolicy');
        });
    });

    describe('beforeAnnotationCreatedHook', function () {
        var sandbox;

        beforeEach(function () {
            sandbox = sinon.sandbox.create();
        });

        afterEach(function () {
            sandbox.restore();
        });

        it('sets the user property of the annotation', function () {
            var policyProto = identity.SimpleIdentityPolicy.prototype;
            sandbox.stub(policyProto, 'who').returns('alice');

            var annotation = {};
            ext.beforeAnnotationCreated(annotation);
            assert.equal(annotation.user, 'alice');
        });
    });
});

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
