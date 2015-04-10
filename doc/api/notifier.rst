.. default-domain: js

annotator.notifier package
==========================

..  class:: annotator.notifier.BannerNotifier(message[, severity=notifier.INFO])
    
    BannerNotifier is simple notifier system that can be used to display
    information, warnings and errors to the user.
    
    :param String message: The notice message text.
    :param severity:
       The severity of the notice (one of `notifier.INFO`, `notifier.SUCCESS`, or
       `notifier.ERROR`)


..  function:: annotator.notifier.BannerNotifier.prototype.close()
    
    Close the notifier.
    
    :returns: The notifier instance.


