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
buildBookmarklet = ->
  template    = "#{BOOKMARKLET_PATH}/dev.html"
  destination = "#{BOOKMARKLET_PATH}/demo.html"
  bookmarklet = "#{BOOKMARKLET_PATH}/src/bookmarklet.js"

  # Compress bookmarklet script and embed in HTML template.
  exec "yuicompressor #{bookmarklet}", (err, stdout, stderr) ->
    if stderr
      console.log "Unable to compress #{bookmarklet}"
      console.log "Output from yuicompressor: \n", stderr
      return;
    throw err if err

    oneline = stdout.toString().replace(/"/g, '&quot;')
    html = fs.readFileSync template
    html = html.toString().replace('{bookmarklet}', oneline)

    fs.writeFileSync destination, html
    console.log "Updated #{destination}"

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
    return if err or stderr

    css = fs.readFileSync source

    # Add !important declarations to compiled CSS but avoid the data uris.
    # I'm sure this could be done far more efficiently.
    css = css.toString().replace(/(image\/png)?;/g, (_, m) ->
      return _ if m == 'image/png'
      '!important;'
    )

    fs.writeFileSync "#{BOOKMARKLET_PATH}/#{source}", css
    console.log "Updated #{BOOKMARKLET_PATH}/#{source}"

task 'bookmarklet:build', 'Watch the bookmarklet source for changes', ->
  buildBookmarklet()
  packageBookmarkletJavaScript()
  packageBookmarkletCSS()

task 'bookmarklet:watch', 'Watch the bookmarklet source for changes', ->
  file = "contrib/bookmarklet/src/bookmarklet.js"
  options = {persistent: true, interval: 500}

  buildBookmarklet()
  console.log "Watching #{file} for changes:"

  fs.watchFile file, options, (curr, prev) ->
      return if curr.size is prev.size and curr.mtime.getTime() is prev.mtime.getTime()

      buildBookmarklet()

