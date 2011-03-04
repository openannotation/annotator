fs = require 'fs'
{print, debug} = require 'sys'
{spawn, exec} = require 'child_process'

# Utility functions

# relay: run child process relaying std{out,err} to this process
relay = (cmd, args, stdoutPrint=print, stderrPrint=debug) ->
  handle = spawn cmd, args

  handle.stdout.on 'data', (data) -> stdoutPrint(data) if data
  handle.stderr.on 'data', (data) -> stderrPrint(data) if data

noisyPrint = (data) ->
  print data
  if data.toString('utf8').indexOf('In') is 0
    exec 'afplay ~/.autotest.d/sound/sound_fx/red.mp3 2>&1 >/dev/null'

task 'watch', 'Run development source watcher', ->
  relay 'coffee', ['-w', '-b', '-c', '-o', 'lib/', 'src/'], noisyPrint

option '-f', '--filter [string]', 'Filename filter to apply to `cake test`'
task 'test', 'Run tests. Filter tests using `-f [filter]` eg. cake -f auth test', (options) ->
  args = ["#{__dirname}/test/runner.coffee"]
  args.push(options.filter) if options.filter

  relay 'coffee', args

# Bookmarklet Tasks

BOOKMARKLET_PATH = "contrib/bookmarklet"

# Create the bookmarklet demo page.
buildBookmarklet = (embedConfig, callback) ->
  bookmarklet = "#{BOOKMARKLET_PATH}/src/bookmarklet.js"
  config      = "#{BOOKMARKLET_PATH}/config.json"
  temp        = "#{BOOKMARKLET_PATH}/temp.js"

  callback = embedConfig if arguments.length == 1

  # Replace the __config__ placeholder with the JSON data.
  config = fs.readFileSync(config).toString()
  source = fs.readFileSync(bookmarklet).toString()
  source = source.toString().replace('__config__', config) unless embedConfig == false

  # Write back out to temp file so YUI can compress it. This needs to be updated
  # with either a compressor than can read from stdin or a Node library.
  fs.writeFileSync temp, source

  # Compress bookmarklet script and embed in HTML template.
  exec "yuicompressor #{temp}", (err, stdout, stderr) ->
    fs.unlinkSync(temp)

    if stderr
      console.log "Unable to compress #{bookmarklet}"
      console.log "Output from yuicompressor: \n", stderr
      return;
    throw err if err

    callback stdout.toString()


packageBookmarkletDemo = ->
  template    = "#{BOOKMARKLET_PATH}/template.html"
  destination = "#{BOOKMARKLET_PATH}/demo.html"

  testTemplate    = "#{BOOKMARKLET_PATH}/test/template.html"
  testDestination = "#{BOOKMARKLET_PATH}/test/runner.html"

  html = fs.readFileSync(template).toString()
  testHtml = fs.readFileSync(testTemplate).toString()

  buildBookmarklet false, (source) ->
     html = html.replace '__bookmarklet__', source.replace(/"/g, '&quot;')
     testHtml = testHtml.replace '__bookmarklet__', source

     fs.writeFileSync destination, html
     fs.writeFileSync testDestination, testHtml

     console.log "Updated #{destination}"
     console.log "Updated #{testDestination}"


# Compile & compress annotator scripts.
packageBookmarkletJavaScript = ->
  destination = "#{BOOKMARKLET_PATH}/pkg/annotator.min.js"
  sources = [
    'extensions', 'console', 'class', 'range', 'annotator', 'editor', 'viewer',
    'notification', 'plugin/store', 'plugin/permissions', 'plugin/unsupported'
  ].map (file) -> "src/#{file}.coffee"

  exec "coffee -jp #{sources.join ' '} > #{destination}", (err, stdout, stderr) ->
    if stderr
      console.log "Unable to compile #{destination}"
      console.log "Output from coffee: \n", stderr
      return;

    exec "yuicompressor -o #{destination} #{destination}", (err, stdout, stderr) ->
      if stderr
        console.log "Unable to compress #{destination}"
        console.log "Output from yuicompressor: \n", stderr
        return;

      console.log "Updated #{destination}"


# Compile CSS and add !important declarations to styles.
packageBookmarkletCSS = ->
  source = 'pkg/annotator.min.css'

  exec 'rake package', (err, stdout, stderr) ->
    if stderr
      console.log stderr
      return
    throw err if err

    css = fs.readFileSync source

    # Add !important declarations to compiled CSS but avoid the data uris.
    # I'm sure this could be done far more efficiently.
    css = css.toString().replace(/(image\/png)?;|\}/g, (_, m) ->
      return _ if m == 'image/png'
      '!important' + _
    )

    fs.writeFileSync "#{BOOKMARKLET_PATH}/#{source}", css
    console.log "Updated #{BOOKMARKLET_PATH}/#{source}"

task 'bookmarklet:build', 'Output bookmarklet source', ->
  buildBookmarklet console.log

task 'bookmarklet:package', 'Compile the bookmarklet source and dependancies', ->
  packageBookmarkletDemo()
  packageBookmarkletJavaScript()
  packageBookmarkletCSS()

task 'bookmarklet:watch', 'Watch the bookmarklet source for changes', ->
  file = "contrib/bookmarklet/src/bookmarklet.js"
  options = {persistent: true, interval: 500}

  packageBookmarkletDemo()
  console.log "Watching #{file} for changes:"

  fs.watchFile file, options, (curr, prev) ->
      return if curr.size is prev.size and curr.mtime.getTime() is prev.mtime.getTime()

      packageBookmarkletDemo()

