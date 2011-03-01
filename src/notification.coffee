Annotator = Annotator || {}

class Annotator.Notification extends Delegator

  events:
    "click": "hide"

  options:
    html: "<div class='annotator-notice'></div>"
    classes:
      show:    "annotator-notice-show"
      info:    "annotator-notice-info"
      success: "annotator-notice-success"
      error:   "annotator-notice-error"

  constructor: (options) ->
    super $(@options.html).appendTo(document.body)[0], options

  show: (message, status=Annotator.Notification.INFO) =>
    $(@element)
      .addClass(@options.classes.show)
      .addClass(@options.classes[status])
      .text(message || "")

    setTimeout this.hide, 5000

  hide: =>
    $(@element).removeClass(@options.classes.show)

Annotator.Notification.INFO    = 'show'
Annotator.Notification.SUCCESS = 'success'
Annotator.Notification.ERROR   = 'error'

# Attach notification methods to the Annotation object on document ready.
$(->
  notification = new Annotator.Notification

  Annotator.showNotification = notification.show
  Annotator.hideNotification = notification.hide
)
