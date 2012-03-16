Date::toISO8601String = DateToISO8601String

describe 'Annotator.Plugin.Auth', ->
  mock = null
  validToken = null

  mockAuth = (options) ->
    el = $('<div></div>')[0]
    a = new Annotator.Plugin.Auth(el, options)

    {
      elem: el,
      auth: a
    }

  beforeEach ->
    validToken = JSON.stringify({
      consumerKey: "key"
      issuedAt: new Date().toISO8601String()
      ttl: 300
      userId: "testUser"
    }) + ".timestamp.signature"

    mock = mockAuth({token: validToken, autoFetch: false})

  it "uses token supplied in options by default", ->
    expect(mock.auth.token).toEqual(validToken)

  xit "makes an ajax request to tokenUrl to retrieve token otherwise"

  it "sets annotator:headers data on its element with token data", ->
    data = $(mock.elem).data('annotator:headers')
    expect(data).not.toBeNull()
    expect(data['x-annotator-auth-token']).toEqual(validToken)

  it "should call callbacks given to #withToken immediately if it has a valid token", ->
    callback = jasmine.createSpy()
    mock.auth.withToken(callback)
    expect(callback).toHaveBeenCalled()

  xit "should call callbacks given to #withToken after retrieving a token"

  describe "#haveValidToken", ->
    it "returns true when the current token is valid", ->
      expect(mock.auth.haveValidToken()).toBeTruthy()

    it "returns false when the current token is missing a consumerKey", ->
      delete mock.auth._unsafeToken.consumerKey
      expect(mock.auth.haveValidToken()).toBeFalsy()

    it "returns false when the current token is missing an issuedAt", ->
      delete mock.auth._unsafeToken.issuedAt
      expect(mock.auth.haveValidToken()).toBeFalsy()

    it "returns false when the current token is missing a ttl", ->
      delete mock.auth._unsafeToken.ttl
      expect(mock.auth.haveValidToken()).toBeFalsy()

    it "returns false when the current token expires in the past", ->
      mock.auth._unsafeToken.ttl = 0
      expect(mock.auth.haveValidToken()).toBeFalsy()
      mock.auth._unsafeToken.ttl = 86400
      mock.auth._unsafeToken.issuedAt = "1970-01-01T00:00"
      expect(mock.auth.haveValidToken()).toBeFalsy()
