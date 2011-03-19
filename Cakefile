fs = require 'fs'
path = require 'path'
{print, debug} = require 'sys'
{spawn, exec} = require 'child_process'

SRC =         ['extensions',
               'console',
               'class',
               'range',
               'annotator',
               'widget',
               'editor',
               'viewer',
               'notification'].map (x) -> "src/#{x}.coffee"

SRC_PLUGINS = ['tags',
               'auth',
               'store',
               'filter',
               'markdown',
               'unsupported',
               'permissions'].map (x) -> "src/plugin/#{x}.coffee"

CSS         = ['annotator'].map (x) -> "css/#{x}.css"

BOOKMARKLET_PATH = 'contrib/bookmarklet'

task 'watch', 'Run development source watcher', ->
  relay 'coffee', ['-w', '-b', '-c', '-o', 'lib/', 'src/'], noisyPrint

option '-f', '--filter [string]', 'Filename filter to apply to `cake test`'

task 'test', 'Run tests. Filter tests using `-f [filter]` eg. cake -f auth test', (options) ->
  args = ["#{__dirname}/test/runner.coffee"]
  args.push(options.filter) if options.filter

  relay 'coffee', args

task 'package', 'Build the packaged annotator', ->
  invoke 'package:annotator'
  invoke 'package:plugins'

task 'package:annotator', 'Build pkg/annotator.min.js', ->
  packager.build_coffee SRC, 'pkg/annotator.min.js' 
  packager.build_css CSS, 'pkg/annotator.min.css' 

task 'package:plugins', 'Build pkg/annotator.<plugin_name>.min.js for all plugins', ->
  for p in SRC_PLUGINS
    packager.build_coffee [p], "pkg/annotator.#{path.basename(p, '.coffee')}.min.js"

task 'package:kitchensink', 'Build pkg/annotator-full.min.js with Annotator and all plugins', ->
  packager.build_coffee SRC.concat(SRC_PLUGINS), 'pkg/annotator-full.min.js'
  packager.build_css CSS, 'pkg/annotator.min.css' 

task 'package:clean', 'Clean package files', ->
  fs.unlink "pkg/annotator.min.css"
  fs.unlink "pkg/annotator.min.js"
  fs.unlink "pkg/annotator-full.min.js"
  for p in SRC_PLUGINS
    fs.unlink "pkg/annotator.#{path.basename(p, '.coffee')}.min.js"

option '-c', '--no-config', 'Do not embed config file'
task 'bookmarklet:build', 'Output bookmarklet source', (options) ->
  config = if options['no-config'] then false else true
  buildBookmarklet config, console.log

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

#----------------------------------------------------------------------------

#
# Packager
#

packager =
  concat: (src, dest, callback) ->
    exec "cat #{src.join ' '} > #{dest}", callback

  concat_coffee: (src, dest, callback) ->
    exec "coffee -jp #{src.join ' '} > #{dest}", callback

  compress: (file, options={ type: 'js' }, callback) ->
    yc = require 'yui-compressor'
    
    yc.compile(fs.readFileSync(file), options, (result) -> 
      fs.writeFile(file, result, callback)  
    )

  build_coffee: (src, dest, callback) ->
    packager.concat_coffee(src, dest, -> 
      packager.compress(dest, callback)
    )

  build_css: (src, dest, callback) ->
    packager.concat(src, dest, -> 
      packager.compress(dest, { type: 'css' }, ->
        packager.data_uri_ify(dest, callback)
      )
    )

  data_uri_ify: (file, callback) ->
    # NB: path to image is "src/..." because the CSS urls start with "../img"
    b64_str = (name) -> fs.readFileSync("src/#{name}.png").toString('base64')
    b64_url = (m...) -> "url('data:image/png;base64,#{b64_str(m[2])}')"

    new_css = fs.readFileSync(file, 'utf8').replace(/(url\(([^)]+)\.png\))/g, b64_url)   
    fs.writeFile(file, new_css, callback)

#
# Bookmarklet Tasks
#

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

  buildBookmarklet (source) ->
    html = html.replace '__bookmarklet__', source.replace(/"/g, '&quot;')
    fs.writeFileSync destination, html
    console.log "Updated #{destination}"

    buildBookmarklet false, (source) ->
      testHtml = testHtml.replace '__bookmarklet__', source
      fs.writeFileSync testDestination, testHtml
      console.log "Updated #{testDestination}"

# Compile & compress annotator scripts.
packageBookmarkletJavaScript = ->
  destination = "#{BOOKMARKLET_PATH}/pkg/annotator.min.js"
  sources = [
    'extensions', 'console', 'class', 'range', 'annotator', 'widget', 'editor',
    'viewer', 'notification', 'plugin/store', 'plugin/permissions',
    'plugin/unsupported', 'plugin/tags'
  ].map (file) -> "src/#{file}.coffee"

  exec "coffee -jp #{sources.join ' '} > #{destination}", (err, stdout, stderr) ->
    if stderr
      console.log "Unable to compile #{destination}"
      console.log "Output from coffee: \n", stderr
      return

    exec "yuicompressor -o #{destination} #{destination}", (err, stdout, stderr) ->
      if stderr
        console.log "Unable to compress #{destination}"
        console.log "Output from yuicompressor: \n", stderr
        return

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

#
# Utility functions
#

# relay: run child process relaying std{out,err} to this process
relay = (cmd, args, stdoutPrint=print, stderrPrint=debug) ->
  handle = spawn cmd, args

  handle.stdout.on 'data', (data) -> stdoutPrint(data) if data
  handle.stderr.on 'data', (data) -> stderrPrint(data) if data

noisyPrint = (data) ->
  print data
  if data.toString('utf8').indexOf('In') is 0
    exec 'afplay ~/.autotest.d/sound/sound_fx/red.mp3 2>&1 >/dev/null'

