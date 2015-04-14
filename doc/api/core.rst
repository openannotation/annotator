.. default-domain: js

annotator.core package
======================

..  class:: annotator.core.Annotator()
    
    Annotator is the coordination point for all annotation functionality. On
    its own it provides only the necessary code for coordinating the lifecycle of
    annotation objects. It requires at least a storage plugin to be useful.


..  function:: annotator.core.Annotator.prototype.addPlugin(plugin)
    
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
      object for the current Annotator and returns a plugin object. A plugin
      object may define function properties wi
    :returns: The Annotator instance, to allow chained method calls.


..  function:: annotator.core.Annotator.prototype.destroy()
    
    Destroy the current instance
    
    Destroys all remnants of the current AnnotatorBase instance by calling the
    destroy method, if it exists, on each plugin object.
    
    :returns Promise: Resolved when all plugin destroy hooks are completed.


..  function:: annotator.core.Annotator.prototype.runHook(name[, args])
    
    Run the named hook with the provided arguments
    
    :returns Promise: Resolved when all over the hook handlers are complete.


..  function:: annotator.core.Annotator.prototype.setStorage(storageFunc)
    
    Set the storage implementation
    
    :param Function storageFunc:
      A function returning a storage component. A storage component must
      implement the Storage interface.
    
    :returns: The Annotator instance, to allow chained method calls.


..  function:: annotator.core.Annotator.extend(object)
    
    Create a new object which inherits from the Annotator class.


