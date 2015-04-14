.. default-domain: js

annotator package
=================

..  class:: annotator.App([options])
    
    App is the coordination point for all annotation functionality. App instances
    manage the configuration of a particular annotation application, and are the
    starting point for most deployments of Annotator.


..  function:: annotator.App.prototype.include(module[, options])
    
    Include a plugin module. If an `options` object is supplied, it will be
    passed to the plugin module at initialisation.
    
    If the returned plugin has a `configure` function, this will be called with
    the application registry as its first parameter.
    
    :param Object module:
    :param Object options:
    :returns: The Annotator instance, to allow chained method calls.


..  function:: annotator.App.prototype.start()
    
    Tell the app that configuration is complete. This binds the various
    components passed to the registry to their canonical names so they can be
    used by the rest of the application.
    
    Runs the 'start' plugin hook.
    
    :returns Promise: Resolved when all plugin 'start' hooks have completed.


..  function:: annotator.App.prototype.runHook(name[, args])
    
    Run the named hook with the provided arguments
    
    :returns Promise: Resolved when all over the hook handlers are complete.


..  function:: annotator.App.prototype.destroy()
    
    Destroy the App. Unbinds all event handlers and runs the 'destroy' plugin
    hook.
    
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


