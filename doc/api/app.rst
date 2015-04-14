.. default-domain: js

annotator package
=================

..  class:: annotator.App([options])
    
    App is the coordination point for all annotation functionality. App instances
    manage the configuration of a particular annotation application, and are the
    starting point for most deployments of Annotator.


..  function:: annotator.App.prototype.start(element)
    
    Start listening for selection events on `element`.


..  function:: annotator.App.prototype.addPlugin(plugin)
    
    Register a plugin
    
    **Examples**:
    
    ::
    
        function creationNotifier(registry) {
            return {
                onAnnotationCreated: function (ann) {
                    console.log("annotationCreated", ann);
                }
            }
        }
    
        annotator
          .addPlugin(annotator.plugin.Tags)
          .addPlugin(creationNotifier)
    
    
    :param plugin:
      A plugin to instantiate. A plugin is a function that accepts a Registry
      object for the current App and returns a plugin object. A plugin
      object may define function properties wi
    :returns: The Annotator instance, to allow chained method calls.


..  function:: annotator.App.prototype.runHook(name[, args])
    
    Run the named hook with the provided arguments
    
    :returns Promise: Resolved when all over the hook handlers are complete.


..  function:: annotator.App.prototype.setStorage(storageFunc)
    
    Set the storage implementation
    
    :param Function storageFunc:
      A function returning a storage component. A storage component must
      implement the Storage interface.
    
    :returns: The App instance, to allow chained method calls.


..  function:: annotator.App.prototype.destroy()
    
    Destroy the App. Unbinds all event handlers and runs the 'onDestroy' hooks
    for any plugins.
    
    :returns Promise: Resolved when destroyed.


..  function:: annotator.App.extend(object)
    
    Create a new object which inherits from the App class.


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


