.. default-domain: js

annotator.notifier package
==========================

..  function:: annotator.notifier.banner(message[, severity=notification.INFO])
    
    Creates a user-visible banner notification that can be used to display
    information, warnings and errors to the user.
    
    :param String message: The notice message text.
    :param severity:
       The severity of the notice (one of `notification.INFO`,
       `notification.SUCCESS`, or `notification.ERROR`)
    
    :returns:
      An object with a `close` method which can be used to close the banner.


