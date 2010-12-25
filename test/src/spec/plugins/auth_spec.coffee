$ = jQuery

describe 'Annotator.Plugins.Auth', () ->
  mock = null
  validToken = null

  mockAuth = (options) ->
    el = $('<div></div>')[0]
    a = new Annotator.Plugins.Auth(el, options)

    {
      elem: el,
      auth: a
    }

  beforeEach () ->
    validToken = {
      consumerKey: "key"
      authToken: "foobar"
      authTokenIssueTime: new Date().toLocaleFormat("%Y-%m-%dT%H:%M:%S%z")
      authTokenTTL: 300
      userId: "testUser"
    }

    mock = mockAuth({token: validToken})

  it "sets annotator:auth data on its element on init", () ->
    expect($(mock.elem).data('annotator:auth')).toBe(mock.auth)

  it "uses token supplied in options by default", () ->
    expect(mock.auth.token).toBe(validToken)

  xit "makes an ajax request to tokenUrl to retrieve token otherwise"

  it "sets annotator:headers data on its element with token data", () ->
    data = $(mock.elem).data('annotator:headers')
    expect(data).not.toBeNull()
    expect(data['x-annotator-auth-token-issue-time']).toEqual(validToken.authTokenIssueTime)


  it "should call callbacks given to #withToken immediately if it has a valid token", () ->
    callback = jasmine.createSpy()
    mock.auth.withToken(callback)
    expect(callback).toHaveBeenCalled()

  xit "should call callbacks given to #withToken after retrieving a token"

  describe "#haveValidToken", () ->
    it "returns true when the current token is valid", () ->
      expect(mock.auth.haveValidToken()).toBeTruthy()

    it "returns false when the current token is missing a consumerKey", () ->
      delete mock.auth.token.consumerKey
      expect(mock.auth.haveValidToken()).toBeFalsy()

    it "returns false when the current token is missing an authToken", () ->
      delete mock.auth.token.authToken
      expect(mock.auth.haveValidToken()).toBeFalsy()

    it "returns false when the current token is missing an authTokenIssueTime", () ->
      delete mock.auth.token.authTokenIssueTime
      expect(mock.auth.haveValidToken()).toBeFalsy()

    it "returns false when the current token is missing an authTokenTTL", () ->
      delete mock.auth.token.authTokenTTL
      expect(mock.auth.haveValidToken()).toBeFalsy()

    it "returns false when the current token is missing a userId", () ->
      delete mock.auth.token.userId
      expect(mock.auth.haveValidToken()).toBeFalsy()

    it "returns false when the current token expires in the past", () ->
      mock.auth.token.authTokenTTL = 0
      expect(mock.auth.haveValidToken()).toBeFalsy()
      mock.auth.token.authTokenTTL = 86400
      mock.auth.token.authTokenIssueTime = "1970-01-01T00:00"
      expect(mock.auth.haveValidToken()).toBeFalsy()