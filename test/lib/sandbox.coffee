fs   = require 'fs'
path = require 'path'

coffeescript = require 'coffee-script'
jsdom        = require 'jsdom'

class Sandbox
  src: """
       <html>
         <head></head>
         <body></body>
       </html>
       """

  constructor: (@root) ->
    # Set up DOM/BOM
    @document = jsdom.jsdom(@src)
    @window = @document.createWindow()

    # Forward console.* calls to Node
    @window.console = console
    @window.alert = (args...) -> console.log "ALERT:", args...

    # Forward require calls to self
    @window.require = this.require

  require: (f) ->
    if f[0] is '/'
      filename = path.normalize f
    else
      filename = path.normalize "#{@root}/#{f}"

    src = fs.readFileSync(filename, 'utf8')

    if path.extname(filename) is '.coffee'
      src = coffeescript.compile(src)

    @window.run(src, filename)

exports.Sandbox = Sandbox
