describe('Annotator.Plugins.Auth', function () {
  var mock, validToken

  var mockAuth = function (options) {
    var el = $('<div></div>')[0]
    var a = new Annotator.Plugins.Auth(options, el)

    return {
      elem: el,
      auth: a
    }
  }

  beforeEach(function () {
    validToken = {
      consumerKey: "key",
      authToken: "foobar",
      authTokenIssueTime: new Date().toLocaleFormat("%Y-%m-%dT%H:%M:%S%z"),
      authTokenTTL: 300,
      userId: "testUser"
    }

    mock = mockAuth({token: validToken})
  })

  it('sets annotator:auth data on its element on init', function () {
    expect($(mock.elem).data('annotator:auth')).toBe(mock.auth)
  })

  it('uses token supplied in options by default', function () {
    expect(mock.auth.token).toBe(validToken)
  })

  xit('makes an ajax request to tokenUrl to retrieve token otherwise')

  it('sets annotator:headers data on its element with token data', function () {
    var data = $(mock.elem).data('annotator:headers')
    expect(data).not.toBeNull()
    expect(data['x-annotator-auth-token-issue-time']).toEqual(validToken.authTokenIssueTime)
  })


  it('should call callbacks given to #withToken immediately if it has a valid token', function () {
    var callback = jasmine.createSpy()
    mock.auth.withToken(callback)
    expect(callback).toHaveBeenCalled()
  })

  xit('should call callbacks given to #withToken after retrieving a token')

  describe('#haveValidToken', function () {
    it('returns true when the current token is valid', function () {
      expect(mock.auth.haveValidToken()).toBeTruthy()
    })

    it('returns false when the current token is missing a consumerKey', function () {
      delete mock.auth.token.consumerKey
      expect(mock.auth.haveValidToken()).toBeFalsy()
    })

    it('returns false when the current token is missing an authToken', function () {
      delete mock.auth.token.authToken
      expect(mock.auth.haveValidToken()).toBeFalsy()
    })

    it('returns false when the current token is missing an authTokenIssueTime', function () {
      delete mock.auth.token.authTokenIssueTime
      expect(mock.auth.haveValidToken()).toBeFalsy()
    })

    it('returns false when the current token is missing an authTokenTTL', function () {
      delete mock.auth.token.authTokenTTL
      expect(mock.auth.haveValidToken()).toBeFalsy()
    })

    it('returns false when the current token is missing a userId', function () {
      delete mock.auth.token.userId
      expect(mock.auth.haveValidToken()).toBeFalsy()
    })

    it('returns false when the current token is missing a userId', function () {
      delete mock.auth.token.userId
      expect(mock.auth.haveValidToken()).toBeFalsy()
    })

    it('returns false when the current token expires in the past', function () {
      mock.auth.token.authTokenTTL = 0
      expect(mock.auth.haveValidToken()).toBeFalsy()
      mock.auth.token.authTokenTTL = 86400
      mock.auth.token.authTokenIssueTime = "1970-01-01T00:00"
      expect(mock.auth.haveValidToken()).toBeFalsy()
    })
  })

})