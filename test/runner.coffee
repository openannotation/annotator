if not phantom?
  console.log "This is a phantomjs script, not a node script. Quitting."
  process.exit 1

if phantom.args.length isnt 1
  console.log 'Usage: phantomjs runner.coffee URL'
  phantom.exit 1

fs = require("fs")
page = require('webpage').create()

DONE = 'phantom:testsComplete:'

page.onConsoleMessage = (msg) ->
  # When we receive the DONE semaphore, quit, setting the exit code to the
  # number of failing tests.
  if msg[...DONE.length] == DONE
    phantom.exit parseInt(msg[DONE.length...])

  # The front-end reporter appends '%%' to the message if it wishes to print
  # "raw" to STDOUT.
  else if msg[-2...] == '%%'
    fs.write("/dev/stdout", msg[...-2], "w")

  else
    console.log msg

page.open phantom.args[0], (status) ->
  if status isnt 'success'
    console.log "Unable to access #{phantom.args[0]}. Perhaps run `cake serve` first?\nQuitting."
    phantom.exit()

  # Otherwise, implicitly enter async event loop...


