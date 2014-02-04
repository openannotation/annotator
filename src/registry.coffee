# Registry is a factory for annotator applications providing a simple runtime
# extension interface and application loader. It is used to pass settings to
# extension modules and provide a means by which extensions can export
# functionality to applications.
class Registry

  # Public: Create an instance of the application defined by the provided
  # module. The application will receive a new registry instance whose settings
  # may be provided as a second argument to this method. The registry will
  # immediately invoke the run callback of the module.
  @createApp: (appModule, settings={}) ->
    (new this(settings)).run(appModule)

  constructor: (@settings={}) ->

  # Public: Include a module. A module is any Object with a fuction property
  # named 'configure`. This function is immediately invoked with the registry
  # instance as the only argument.
  include: (module) ->
    module.configure(this)
    this

  # Public: Run an application. An application is a module with a function
  # property named 'run'. The application is immediately included and its run
  # callback invoked with the registry instance as the only argument.
  run: (app) ->
    if this.app
      throw new Error("Registry is already bound to a running application")

    this.include(app)

    for own k, v of this
      app[k] = v

    this.app = app
    app.run(this)

module.exports = Registry
