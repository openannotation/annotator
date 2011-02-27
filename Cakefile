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

outputError = () ->

buildBookmarklet = ->
  root        = "contrib/bookmarklet"
  template    = "#{root}/dev.html"
  destination = "#{root}/demo.html"
  bookmarklet = "#{root}/src/bookmarklet.js"
  javascript  = "#{root}/pkg/annotator.min.js"

  sources = [
    'extensions', 'console', 'class', 'range', 'annotator', 'editor', 'viewer',
    'notification', 'plugin/store', 'plugin/permissions', 'plugin/unsupported'
  ].map (file) -> "src/#{file}.coffee"

  # Copy CSS over to the package.
  exec "rake package && cp pkg/annotator.min.css #{root}/pkg/"

  # Compile and compress required scripts.
  exec "coffee -jp #{sources.join ' '} > #{javascript}", (err, stdout, stderr) ->
    if stderr
      console.log "Unable to compile #{javascript}"
      console.log "Output from coffee: \n", stderr
      return;

    exec "yuicompressor -o #{javascript} #{javascript}", (err, stdout, stderr) ->
      if stderr
        console.log "Unable to compress #{bookmarklet}"
        console.log "Output from yuicompressor: \n", stderr
        return;

      console.log "Updated #{javascript}" unless stderr

  # Compress bookmarklet script and embed in HTML template.
  exec "yuicompressor #{bookmarklet}", (err, stdout, stderr) ->
    if stderr
      console.log "Unable to compress #{bookmarklet}"
      console.log "Output from yuicompressor: \n", stderr
      return;

    throw err if err

    oneline = stdout.toString().replace(/"/g, '&quot;')
    fs.readFile template, (err, html) ->
      throw err if err

      html = html.toString().replace('{bookmarklet}', oneline)
      fs.writeFile destination, html, (err) ->
        throw err if err
        console.log "Updated #{destination}"

task 'bookmarklet:build', 'Watch the bookmarklet source for changes', ->
  buildBookmarklet()

task 'bookmarklet:watch', 'Watch the bookmarklet source for changes', ->
  file = "contrib/bookmarklet/src/bookmarklet.js"
  options = {persistent: true, interval: 500}

  buildBookmarklet()
  console.log "Watching #{file} for changes:"

  fs.watchFile file, options, (curr, prev) ->
      return if curr.size is prev.size and curr.mtime.getTime() is prev.mtime.getTime()

      buildBookmarklet()

