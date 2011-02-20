Annotator = Annotator || {}

class Annotator.Notification extends Delegator

  events:
    "click": "hide"

  options:
    html: "<div class='annotator-notice'></div>"
    classes:
      show: "show"

  constructor: (options) ->
    super $(@options.html).appendTo(document.body, options)
    this.addEvents()

  show: (message) =>
    @element.addClass(@options.classes.show).text(message || "")

    setTimeout this.hide, 5000

  hide: =>
    console.log 'cllicked'
    @element.removeClass(@options.classes.show)

# Attach notification methods to the Annotation object on document ready.
$(->
  notification = new Annotator.Notification

  Annotator.showNotification = notification.show
  Annotator.hideNotification = notification.hide
)
