;(function($) {

Date.prototype.setISO8601 = function (string) {
  var regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
      "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
      "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?"
  var d = string.match(new RegExp(regexp))

  var offset = 0
  var date = new Date(d[1], 0, 1)

  if (d[3]) { date.setMonth(d[3] - 1) }
  if (d[5]) { date.setDate(d[5]) }
  if (d[7]) { date.setHours(d[7]) }
  if (d[8]) { date.setMinutes(d[8]) }
  if (d[10]) { date.setSeconds(d[10]) }
  if (d[12]) { date.setMilliseconds(Number("0." + d[12]) * 1000) }
  if (d[14]) {
    offset = (Number(d[16]) * 60) + Number(d[17])
    offset *= ((d[15] == '-') ? 1 : -1)
  }

  offset -= date.getTimezoneOffset()
  time = (Number(date) + (offset * 60 * 1000))
  this.setTime(Number(time))
  return this
}

Annotator.Plugins.Auth = DelegatorClass.extend({
  options: {
    token: null,
    tokenUrl: '/auth/token'
  },

  init: function(options, element) {
    this.options = $.extend(this.options, options)
    this.element = element
    this._super()

    // Reference self on element so store knows to wait for auth token.
    $(this.element).data('annotator:auth', this)

    // List of functions to be executed when we have a valid token.
    this.waitingForToken = []

    if (!this.options.token) {
      this.requestToken()
    } else {
      this.setToken(this.options.token)
    }
  },

  // Get a new token from consumer web service
  requestToken: function () {
    this.requestInProgress = true

    var self = this

    $.getJSON(this.options.tokenUrl, function (data, status, xhr) {
      if (status !== 'success') {
        console.error("Couldn't get auth token: " + status, xhr)
      } else {
        self.setToken(data)
        self.requestInProgress = false
      }
    })
  },

  setToken: function (token) {
    var self = this
    this.token = token

    if (this.haveValidToken()) {
      // Set timeout to retrieve a new token 10s before this one
      // expires.
      var beforeExpiry = this.timeToExpiry() - 10
      this.refreshTimeout = setTimeout(function () {
        self.requestToken()
      }, beforeExpiry * 1000)

      // Set headers field on this.element
      this.updateHeaders()

      // Run callbacks waiting for token
      while (this.waitingForToken.length > 0) {
        this.waitingForToken.pop().apply()
      }
    } else {
      console.warn("Didn't get a valid token. Retrying...")
      this.requestToken()
    }
  },

  haveValidToken: function () {
    return this.token &&
           this.token.authToken &&
           this.token.authTokenIssueTime &&
           this.token.authTokenTTL &&
           this.token.consumerKey &&
           this.token.userId
  },

  // Return time to expiry in seconds
  timeToExpiry: function () {
    var now = new Date().getTime() / 1000
    var issue = new Date().setISO8601(this.token.authTokenIssueTime).getTime() / 1000

    var expiry = issue + this.token.authTokenTTL
    var timeToExpiry = expiry - now
    return (timeToExpiry > 0) ? timeToExpiry : 0
  },

  // Update headers to be sent with request
  updateHeaders: function () {
    var current = $(this.element).data('annotator:headers')
    $(this.element).data('annotator:headers', $.extend(current, {
      'x-annotator-auth-token':            this.token.authToken,
      'x-annotator-auth-token-issue-time': this.token.authTokenIssueTime,
      'x-annotator-auth-token-ttl':        this.token.authTokenTTL,
      'x-annotator-consumer-key':          this.token.consumerKey,
      'x-annotator-user-id':               this.token.userId
    }))
  },

  withToken: function (callback) {
    if (!callback) { return }

    if (this.haveValidToken()) {
      callback()
    } else {
      this.waitingForToken.push(callback)
      if (!this.requestInProgress) {
        this.requestToken()
      }
    }
  }

})

})(jQuery)
