createDateFromISO8601 = (string) ->
  regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
           "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
           "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?"

  d = string.match(new RegExp(regexp))

  offset = 0
  date = new Date(d[1], 0, 1)

  date.setMonth(d[3] - 1) if d[3]
  date.setDate(d[5]) if d[5]
  date.setHours(d[7]) if d[7]
  date.setMinutes(d[8]) if d[8]
  date.setSeconds(d[10]) if d[10]
  date.setMilliseconds(Number("0." + d[12]) * 1000) if d[12]

  if d[14]
    offset = (Number(d[16]) * 60) + Number(d[17])
    offset *= ((d[15] == '-') ? 1 : -1)

  offset -= date.getTimezoneOffset()
  time = (Number(date) + (offset * 60 * 1000))

  date.setTime(Number(time))
  date

class Annotator.Plugin.Auth extends Annotator.Plugin
  options:
    token: null
    tokenUrl: '/auth/token'
    autoFetch: true

  constructor: (element, options) ->
    super
    this.addEvents()

    # Reference self on element so store knows to wait for auth token.
    $(@element).data('annotator:auth', this)

    # List of functions to be executed when we have a valid token.
    @waitingForToken = []

    if @options.token
      this.setToken(@options.token)
    else
      this.requestToken()

  # Get a new token from consumer web service
  requestToken: ->
    @requestInProgress = true

    $.getJSON(@options.tokenUrl, (data, status, xhr) =>
      if status isnt 'success'
        console.error "Couldn't get auth token: #{status}", xhr
      else
        @setToken(data)
        @requestInProgress = false
    )

  setToken: (token) ->
    @token = token

    if this.haveValidToken()
      if @options.autoFetch
        # Set timeout to fetch new token 2 seconds before current token expiry
        @refreshTimeout = setTimeout (() => this.requestToken()), (this.timeToExpiry() - 2) * 1000

      # Set headers field on this.element
      this.updateHeaders()

      # Run callbacks waiting for token
      while @waitingForToken.length > 0
        @waitingForToken.pop().apply()

    else
      console.warn "Didn't get a valid token."
      if @options.autoFetch
        console.warn "Getting a new token in 10s."
        setTimeout (() => this.requestToken()), 10 * 1000

  haveValidToken: () =>
    allFields = @token &&
                @token.authToken &&
                @token.authTokenIssueTime &&
                @token.authTokenTTL &&
                @token.consumerKey &&
                @token.userId

    allFields && this.timeToExpiry() > 0

  # Return time to expiry in seconds
  timeToExpiry: ->
    now = new Date().getTime() / 1000
    issue = createDateFromISO8601(@token.authTokenIssueTime).getTime() / 1000

    expiry = issue + @token.authTokenTTL
    timeToExpiry = expiry - now

    if (timeToExpiry > 0) then timeToExpiry else 0

  # Update headers to be sent with request
  updateHeaders: ->
    current = $(@element).data('annotator:headers')
    $(@element).data('annotator:headers', $.extend(current, {
      'x-annotator-auth-token':            @token.authToken,
      'x-annotator-auth-token-issue-time': @token.authTokenIssueTime,
      'x-annotator-auth-token-ttl':        @token.authTokenTTL,
      'x-annotator-consumer-key':          @token.consumerKey,
      'x-annotator-user-id':               @token.userId
    }))

  # Run callback, but only when we have a valid token.
  withToken: (callback) ->
    if not callback?
      return

    if this.haveValidToken()
      callback()
    else
      this.waitingForToken.push(callback)
      if not @requestInProgress
        this.requestToken()
