# Public: Creates a Date object from an ISO8601 formatted date String.
#
# string - ISO8601 formatted date String.
#
# Returns Date instance.
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

# Public: Supports the Store plugin by providing Authentication headers.
class Annotator.Plugin.Auth extends Annotator.Plugin
  # User options that can be provided.
  options:

    # An authentication token. Used to skip the request to the server for a
    # a token.
    token: null

    # The URL on the local server to request an authentication token.
    tokenUrl: '/auth/token'

    # If true will try and fetch a token when the plugin is initialised.
    autoFetch: true

  # Public: Create a new instance of the Auth plugin.
  #
  # element - The element to bind all events to. Usually the Annotator#element.
  # options - An Object literal containing user options.
  #
  # Examples
  #
  #   plugin = new Annotator.Plugin.Auth(annotator.element, {
  #     tokenUrl: '/my/custom/path'
  #   })
  #
  # Returns instance of Auth.
  constructor: (element, options) ->
    super

    # List of functions to be executed when we have a valid token.
    @waitingForToken = []

    if @options.token
      this.setToken(@options.token)
    else
      this.requestToken()

  # Public: Makes a request to the local server for an authentication token.
  #
  # Examples
  #
  #   auth.requestToken()
  #
  # Returns jqXHR object.
  requestToken: ->
    @requestInProgress = true

    $.ajax
      url: @options.tokenUrl
      dataType: 'text'
      xhrFields:
        withCredentials: true # Send any auth cookies to the backend

    # on success, set the auth token
    .done (data, status, xhr) =>
      this.setToken(data)

    # on failure, relay any message given by the server to the user with a notification
    .fail (xhr, status, err) =>
      msg = Annotator._t("Couldn't get auth token:")
      console.error "#{msg} #{err}", xhr
      Annotator.showNotification("#{msg} #{xhr.responseText}", Annotator.Notification.ERROR)

    # always reset the requestInProgress indicator
    .always =>
      @requestInProgress = false

  # Public: Sets the @token and checks it's validity. If the token is invalid
  # requests a new one from the server.
  #
  # token - A token string.
  #
  # Examples
  #
  #   auth.setToken('{
  #     authTokenIssueTime: "2002-03-15T15:02:02Z",
  #     authTokenTTL: 86400,
  #     consumerKey: "unique-string"
  #   }.AkOV6g.SKQMC7ybClqdLR2Wjl-JhUFzasM')
  #
  # Returns nothing.
  setToken: (token) ->
    @token = token
    # Parse the token without verifying its authenticity:
    @_unsafeToken = JSON.parse(token.split('.')[0...-2].join())

    if this.haveValidToken()
      if @options.autoFetch
        # Set timeout to fetch new token 2 seconds before current token expiry
        @refreshTimeout = setTimeout (() => this.requestToken()), (this.timeToExpiry() - 2) * 1000

      # Set headers field on this.element
      this.updateHeaders()

      # Run callbacks waiting for token
      while @waitingForToken.length > 0
        @waitingForToken.pop()(@_unsafeToken)

    else
      console.warn Annotator._t("Didn't get a valid token.")
      if @options.autoFetch
        console.warn Annotator._t("Getting a new token in 10s.")
        setTimeout (() => this.requestToken()), 10 * 1000

  # Public: Checks the validity of the current token. Note that this *does
  # not* check the authenticity of the token.
  #
  # Examples
  #
  #   auth.haveValidToken() # => Returns true if valid.
  #
  # Returns true if the token is valid.
  haveValidToken: () ->
    allFields = @_unsafeToken &&
                @_unsafeToken.authTokenIssueTime &&
                @_unsafeToken.authTokenTTL &&
                @_unsafeToken.consumerKey

    allFields && this.timeToExpiry() > 0

  # Public: Calculates the time in seconds until the current token expires.
  #
  # Returns Number of seconds until token expires.
  timeToExpiry: ->
    now = new Date().getTime() / 1000
    issue = createDateFromISO8601(@_unsafeToken.authTokenIssueTime).getTime() / 1000

    expiry = issue + @_unsafeToken.authTokenTTL
    timeToExpiry = expiry - now

    if (timeToExpiry > 0) then timeToExpiry else 0

  # Public: Updates the headers to be sent with the Store requests. This is
  # achieved by updating the 'annotator:headers' key in the @element.data()
  # store.
  #
  # Returns nothing.
  updateHeaders: ->
    current = @element.data('annotator:headers')
    @element.data('annotator:headers', $.extend(current, {
      'x-annotator-auth-token': @token,
    }))

  # Runs the provided callback if a valid token is available. Otherwise requests
  # a token until it recieves a valid one.
  #
  # callback - A callback function to call once a valid token is obtained.
  #
  # Examples
  #
  #   auth.withToken ->
  #     store.loadAnnotations()
  #
  # Returns nothing.
  withToken: (callback) ->
    if not callback?
      return

    if this.haveValidToken()
      callback(@token)
    else
      this.waitingForToken.push(callback)
      if not @requestInProgress
        this.requestToken()
