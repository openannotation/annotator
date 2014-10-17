var assert = require('assertive-chai').assert;

var h = require('../../helpers');

var Auth = require('../../../src/plugin/auth');

var B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

function base64Encode(data) {
    var ac, bits, enc, h1, h2, h3, h4, i, o1, o2, o3, r, tmpArr;
    if (typeof btoa !== "undefined" && btoa !== null) {
        // Gecko and Webkit provide native code for this
        return btoa(data);
    } else {
        // Adapted from MIT/BSD licensed code at
        // http://phpjs.org/functions/base64_encode
        // version 1109.2015
        i = 0;
        ac = 0;
        enc = "";
        tmpArr = [];
        if (!data) {
            return data;
        }
        data += '';
        while (i < data.length) {
            // pack three octets into four hexets
            o1 = data.charCodeAt(i++);
            o2 = data.charCodeAt(i++);
            o3 = data.charCodeAt(i++);
            bits = o1 << 16 | o2 << 8 | o3;
            h1 = bits >> 18 & 0x3f;
            h2 = bits >> 12 & 0x3f;
            h3 = bits >> 6 & 0x3f;
            h4 = bits & 0x3f;
            // use hexets to index into b64, and append result to encoded string
            tmpArr[ac++] = B64.charAt(h1) + B64.charAt(h2) + B64.charAt(h3) + B64.charAt(h4);
        }
        enc = tmpArr.join('');
        r = data.length % 3;
        return (r ? enc.slice(0, r - 3) : enc) + '==='.slice(r || 3);
    }
}

function base64UrlEncode(data) {
    var chop;
    data = base64Encode(data);
    chop = data.indexOf('=');
    if (chop !== -1) {
        data = data.slice(0, chop);
    }
    data = data.replace(/\+/g, '-');
    data = data.replace(/\//g, '_');
    return data;
}

function makeToken() {
    var rawToken;
    rawToken = {
        consumerKey: "key",
        issuedAt: h.DateToISO8601String.call(new Date()),
        ttl: 300,
        userId: "testUser"
    };
    return {
        rawToken: rawToken,
        encodedToken: 'header.' + base64UrlEncode(JSON.stringify(rawToken)) + '.signature'
    };
}

describe('Auth plugin', function () {
    var auth = null,
        rawToken = null,
        encodedToken = null;

    beforeEach(function () {
        var tok = makeToken();

        rawToken = tok.rawToken;
        encodedToken = tok.encodedToken;

        auth = new Auth({
            token: encodedToken,
            autoFetch: false
        });

        auth.annotator = {
            store: {
                setHeader: sinon.spy()
            }
        };

        auth.pluginInit();
    });

    it("uses token supplied in options by default", function () {
        assert.equal(auth.token, encodedToken);
    });

    xit("makes an ajax request to tokenUrl to retrieve token otherwise");

    it("sets a custom store header with token data", function () {
        assert.isTrue(auth.annotator.store.setHeader.calledWith('x-annotator-auth-token', encodedToken));
    });

    it("should call callbacks given to #withToken immediately if it has a valid token", function () {
        var callback = sinon.spy();
        auth.withToken(callback);
        assert.isTrue(callback.calledWith(rawToken));
    });

    xit("should call callbacks given to #withToken after retrieving a token");

    describe("#haveValidToken", function () {
        it("returns true when the current token is valid", function () {
            assert.isTrue(auth.haveValidToken());
        });

        it("returns false when the current token is missing a consumerKey", function () {
            delete auth._unsafeToken.consumerKey;
            assert.isFalse(auth.haveValidToken());
        });

        it("returns false when the current token is missing an issuedAt", function () {
            delete auth._unsafeToken.issuedAt;
            assert.isFalse(auth.haveValidToken());
        });

        it("returns false when the current token is missing a ttl", function () {
            delete auth._unsafeToken.ttl;
            assert.isFalse(auth.haveValidToken());
        });

        it("returns false when the current token expires in the past", function () {
            auth._unsafeToken.ttl = 0;
            assert.isFalse(auth.haveValidToken());

            auth._unsafeToken.ttl = 86400;
            auth._unsafeToken.issuedAt = "1970-01-01T00:00";
            assert.isFalse(auth.haveValidToken());
        });
    });
});
