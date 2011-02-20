class Annotator.Plugin.Unsupported extends Annotator.Plugin
  options:
    message: "Sorry your current browser does not support the Annotator"

  pluginInit: ->
    unless Annotator.supported()
      $(=>
        # On document load display notification.
        Annotator.showNotification(@options.message)
      )
