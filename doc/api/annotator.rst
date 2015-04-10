.. default-domain: js

annotator package
=================

..  class:: annotator.Annotator(element[, options])
    
    Annotator represents a reasonable default annotator configuration,
    providing a default set of plugins and a user interface.
    
    NOTE: If the Annotator is not supported by the current browser it will
    not perform any setup and simply return a basic object. This allows
    plugins to still be loaded but will not function as expected. It is
    reccomended to call Annotator.supported() before creating the instance or
    using the Unsupported plugin which will notify users that the Annotator
    will not work.
    
    **Examples**:
    
    ::
    
        var app = new annotator.Annotator(document.body);
    
    :param Element element: DOM Element to attach to.
    :param Object options: Configuration options.


..  function:: annotator.Annotator.prototype.destroy()
    
    Destroy the current Annotator instance, unbinding all events and
    disposing of all relevant elements.


..  function:: annotator.supported([details=false, scope=window])
    
    Examines `scope` (by default the global window object) to determine if
    Annotator can be used in this environment.
    
    :returns Boolean:
      Whether Annotator can be used in `scope`, if `details` is
      false.
    :returns Object:
      If `details` is true. Properties:
    
      - `supported`: Boolean, whether Annotator can be used in `scope`.
      - `details`: Array of String reasons why Annotator cannot be used.


