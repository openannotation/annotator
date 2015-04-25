.. default-domain: js

annotator package
=================

..  class:: annotator.App()
    
    App is the coordination point for all annotation functionality. App instances
    manage the configuration of a particular annotation application, and are the
    starting point for most deployments of Annotator.


..  function:: annotator.App.prototype.include(module[, options])
    
    Include an extension module. If an `options` object is supplied, it will be
    passed to the module at initialisation.
    
    If the returned module instance has a `configure` function, this will be
    called with the application registry as a parameter.
    
    :param Object module:
    :param Object options:
    :returns: Itself.
    :rtype: App


..  function:: annotator.App.prototype.start()
    
    Tell the app that configuration is complete. This binds the various
    components passed to the registry to their canonical names so they can be
    used by the rest of the application.
    
    Runs the 'start' module hook.
    
    :returns: A promise, resolved when all module 'start' hooks have completed.
    :rtype: Promise


..  function:: annotator.App.prototype.destroy()
    
    Destroy the App. Unbinds all event handlers and runs the 'destroy' module
    hook.
    
    :returns: A promise, resolved when destroyed.
    :rtype: Promise


..  function:: annotator.App.prototype.runHook(name[, args])
    
    Run the named module hook and return a promise of the results of all the hook
    functions. You won't usually need to run this yourself unless you are
    extending the base functionality of App.
    
    Optionally accepts an array of argument (`args`) to pass to each hook
    function.
    
    :returns: A promise, resolved when all hooks are complete.
    :rtype: Promise


..  function:: annotator.App.extend(object)
    
    Create a new object that inherits from the App class.
    
    For example, here we create a ``CustomApp`` that will include the
    hypothetical ``mymodules.foo.bar`` module depending on the options object
    passed into the constructor::
    
        var CustomApp = annotator.App.extend({
            constructor: function (options) {
                App.apply(this);
                if (options.foo === 'bar') {
                    this.include(mymodules.foo.bar);
                }
            }
        });
    
        var app = new CustomApp({foo: 'bar'});
    
    :returns: The subclass constructor.
    :rtype: Function


