Date::toISO8601String = DateToISO8601String

B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="

base64Encode = (data) ->
  if btoa?
    # Gecko and Webkit provide native code for this
    btoa(data)
  else
    # Adapted from MIT/BSD licensed code at http://phpjs.org/functions/base64_encode
    # version 1109.2015
    i = 0
    ac = 0
    enc = ""
    tmp_arr = []

    if not data
      return data

    data += ''

    while i < data.length
      # pack three octets into four hexets
      o1 = data.charCodeAt(i++)
      o2 = data.charCodeAt(i++)
      o3 = data.charCodeAt(i++)

      bits = o1 << 16 | o2 << 8 | o3

      h1 = bits >> 18 & 0x3f
      h2 = bits >> 12 & 0x3f
      h3 = bits >> 6 & 0x3f
      h4 = bits & 0x3f

      # use hexets to index into b64, and append result to encoded string
      tmp_arr[ac++] = B64.charAt(h1) + B64.charAt(h2) + B64.charAt(h3) + B64.charAt(h4)

    enc = tmp_arr.join('')

    r = data.length % 3
    return (if r then enc.slice(0, r - 3) else enc) + '==='.slice(r or 3)

base64UrlEncode = (data) ->
  data = base64Encode(data)
  chop = data.indexOf('=')
  data = data[...chop] if chop isnt -1
  data = data.replace(/\+/g, '-')
  data = data.replace(/\//g, '_')
  data

makeToken = () ->
  rawToken = {
    consumerKey: "key"
    issuedAt: new Date().toISO8601String()
    ttl: 300
    userId: "testUser"
  }
  {
    rawToken: rawToken
    encodedToken: 'header.' + base64UrlEncode(JSON.stringify(rawToken)) + '.signature'
  }

describe 'Annotator.Plugin.Auth', ->
  mock = null
  rawToken = null
  encodedToken = null

  mockAuth = (options) ->
    el = $('<div></div>')[0]
    a = new Annotator.Plugin.Auth(el, options)

    {
      elem: el,
      auth: a
    }

  beforeEach ->
    {rawToken, encodedToken} = makeToken()
    mock = mockAuth({token: encodedToken, autoFetch: false})

  it "uses token supplied in options by default", ->
    assert.equal(mock.auth.token, encodedToken)

  xit "makes an ajax request to tokenUrl to retrieve token otherwise"

  it "sets annotator:headers data on its element with token data", ->
    data = $(mock.elem).data('annotator:headers')
    assert.isNotNull(data)
    assert.equal(data['x-annotator-auth-token'], encodedToken)

  it "should call callbacks given to #withToken immediately if it has a valid token", ->
    callback = sinon.spy()
    mock.auth.withToken(callback)
    assert.isTrue(callback.calledWith(rawToken))

  xit "should call callbacks given to #withToken after retrieving a token"

  describe "#haveValidToken", ->
    it "returns true when the current token is valid", ->
      assert.isTrue(mock.auth.haveValidToken())

    it "returns false when the current token is missing a consumerKey", ->
      delete mock.auth._unsafeToken.consumerKey
      assert.isFalse(mock.auth.haveValidToken())

    it "returns false when the current token is missing an issuedAt", ->
      delete mock.auth._unsafeToken.issuedAt
      assert.isFalse(mock.auth.haveValidToken())

    it "returns false when the current token is missing a ttl", ->
      delete mock.auth._unsafeToken.ttl
      assert.isFalse(mock.auth.haveValidToken())

    it "returns false when the current token expires in the past", ->
      mock.auth._unsafeToken.ttl = 0
      assert.isFalse(mock.auth.haveValidToken())
      mock.auth._unsafeToken.ttl = 86400
      mock.auth._unsafeToken.issuedAt = "1970-01-01T00:00"
      assert.isFalse(mock.auth.haveValidToken())
