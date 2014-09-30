Util = require('./util')
$ = Util.$

INFO = 'info'
SUCCESS = 'success'
ERROR = 'error'

# Public: A simple notification system that can be used to display information,
# warnings and errors to the user.
class BannerNotification

  template: "<div class='annotator-notice'></div>"

  classes:
    show: "annotator-notice-show"
    info: "annotator-notice-info"
    success: "annotator-notice-success"
    error: "annotator-notice-error"

  # Public: Creates an instance of BannerNotification and appends it to the
  # document body.
  #
  # message - The notification message text
  # severity - The severity of the message (one of Notification.INFO,
  #            Notification.SUCCESS, or Notification.ERROR)
  #
  constructor: (message, severity = INFO) ->
    @element = $(@template)[0]
    @severity = severity
    @closed = false

    $(@element)
      .addClass(@classes.show)
      .addClass(@classes[@severity])
      .html(Util.escape(message || ""))
      .appendTo(Util.getGlobal().document.body)

    $(@element)
      .on('click', => this.close())

    # Hide the notification after 5s
    setTimeout =>
      this.close()
    , 5000

  # Public: Close the notification.
  #
  # Returns the instance.
  close: ->
    if @closed
      return

    @closed = true

    $(@element)
      .removeClass(@classes.show)
      .removeClass(@classes[@severity])

    # The removal of the above classes triggers a 400ms ease-out transition, so
    # we can dispose the element from the DOM after 500ms.
    setTimeout =>
      $(@element).remove()
    , 500

    return this


exports.Banner = ->
  create: (message, severity) -> new BannerNotification(message, severity)

# Constants for controlling the display of the notification. Each constant
# adds a different class to the Notification#element.
exports.INFO = INFO
exports.SUCCESS = SUCCESS
exports.ERROR = ERROR
