Evented = require('./events')


class Registry extends Evented
  @createApp: (appModule, settings) ->
    (new this(settings)).run(appModule)

  constructor: (@settings={}) ->
    super

  include: (module) ->
    module?.configure(this)
    this

  run: (app) ->
    if this.app
      throw new Error("This registry already has an application.")

    this.include(app)

    for own k, v of this
      app[k] = v

    this.app = app
    app.run?()

module.exports = Registry
