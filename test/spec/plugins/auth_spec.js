(function() {
  var $;
  $ = jQuery;
  describe('Annotator.Plugins.Auth', function() {
    var mock, mockAuth, validToken;
    mock = null;
    validToken = null;
    mockAuth = function(options) {
      var a, el;
      el = $('<div></div>')[0];
      a = new Annotator.Plugins.Auth(el, options);
      return {
        elem: el,
        auth: a
      };
    };
    beforeEach(function() {
      validToken = {
        consumerKey: "key",
        authToken: "foobar",
        authTokenIssueTime: new Date().toLocaleFormat("%Y-%m-%dT%H:%M:%S%z"),
        authTokenTTL: 300,
        userId: "testUser"
      };
      return mock = mockAuth({
        token: validToken
      });
    });
    it("sets annotator:auth data on its element on init", function() {
      return expect($(mock.elem).data('annotator:auth')).toBe(mock.auth);
    });
    it("uses token supplied in options by default", function() {
      return expect(mock.auth.token).toBe(validToken);
    });
    xit("makes an ajax request to tokenUrl to retrieve token otherwise");
    it("sets annotator:headers data on its element with token data", function() {
      var data;
      data = $(mock.elem).data('annotator:headers');
      expect(data).not.toBeNull();
      return expect(data['x-annotator-auth-token-issue-time']).toEqual(validToken.authTokenIssueTime);
    });
    it("should call callbacks given to #withToken immediately if it has a valid token", function() {
      var callback;
      callback = jasmine.createSpy();
      mock.auth.withToken(callback);
      return expect(callback).toHaveBeenCalled();
    });
    xit("should call callbacks given to #withToken after retrieving a token");
    return describe("#haveValidToken", function() {
      it("returns true when the current token is valid", function() {
        return expect(mock.auth.haveValidToken()).toBeTruthy();
      });
      it("returns false when the current token is missing a consumerKey", function() {
        delete mock.auth.token.consumerKey;
        return expect(mock.auth.haveValidToken()).toBeFalsy();
      });
      it("returns false when the current token is missing an authToken", function() {
        delete mock.auth.token.authToken;
        return expect(mock.auth.haveValidToken()).toBeFalsy();
      });
      it("returns false when the current token is missing an authTokenIssueTime", function() {
        delete mock.auth.token.authTokenIssueTime;
        return expect(mock.auth.haveValidToken()).toBeFalsy();
      });
      it("returns false when the current token is missing an authTokenTTL", function() {
        delete mock.auth.token.authTokenTTL;
        return expect(mock.auth.haveValidToken()).toBeFalsy();
      });
      it("returns false when the current token is missing a userId", function() {
        delete mock.auth.token.userId;
        return expect(mock.auth.haveValidToken()).toBeFalsy();
      });
      return it("returns false when the current token expires in the past", function() {
        mock.auth.token.authTokenTTL = 0;
        expect(mock.auth.haveValidToken()).toBeFalsy();
        mock.auth.token.authTokenTTL = 86400;
        mock.auth.token.authTokenIssueTime = "1970-01-01T00:00";
        return expect(mock.auth.haveValidToken()).toBeFalsy();
      });
    });
  });
}).call(this);
