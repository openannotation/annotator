.. default-domain: js

annotator.ui package
====================

..  function:: annotator.ui.main([options])
    
    A module that provides a default user interface for Annotator that allows
    users to create annotations by selecting text within (a part of) the
    document.
    
    Example::
    
        app.include(annotator.ui.main);
    
    :param Object options:
    
      .. attribute:: options.element
    
         A DOM element to which to bind event listeners. Defaults to
         ``document.body``, allowing annotation of the whole document.


