# Plugin that will display a notification to the user if thier browser does
# not support the Annotator.
class Annotator.Plugin.Unsupported extends Annotator.Plugin
  # Options Object, message sets the message displayed in the browser.
  options:
    message: "Sorry your current browser does not support the Annotator"

  # Public: Checks the Annotator.supported() method and if unsupported displays
  # @options.message in a notification.
  #
  # Returns nothing.
  pluginInit: ->
    unless Annotator.supported()
      $(=>
        # On document load display notification.
        Annotator.showNotification(@options.message)
      )
