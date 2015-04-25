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
    
         A DOM element to which event listeners are bound. Defaults to
         ``document.body``, allowing annotation of the whole document.
    
      .. attribute:: options.editorExtensions
    
         An array of editor extensions. See the
         :class:`~annotator.ui.editor.Editor` documentation for details of editor
         extensions.
    
      .. attribute:: options.viewerExtensions
    
         An array of viewer extensions. See the
         :class:`~annotator.ui.viewer.Viewer` documentation for details of viewer
         extensions.


