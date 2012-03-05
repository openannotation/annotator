fs = require 'fs'
path = require 'path'
{print, debug} = require 'sys'
{spawn, exec} = require 'child_process'

CORE = [ 'extensions'
       , 'console'
       , 'class'
       , 'range'
       , 'annotator'
       , 'widget'
       , 'editor'
       , 'viewer'
       , 'notification'
       ]

PLUGINS = [ 'tags'
          , 'auth'
          , 'store'
          , 'filter'
          , 'markdown'
          , 'unsupported'
          , 'permissions'
          , 'categories'
          ]

BOOKMARKLET_PATH = 'contrib/bookmarklet'
BOOKMARKLET_PLUGINS = ['store', 'permissions', 'unsupported', 'tags']

task 'watch', 'Run development source watcher', ->
  util.relay 'coffee', ['-w', '-b', '-c', '-o', 'lib/', 'src/'], util.noisyPrint

option '-f', '--filter [string]', 'Filename filter to apply to `cake test`'

task 'test', 'Run tests. Filter tests using `-f [filter]` eg. cake -f auth test', (options) ->
  args = ["#{__dirname}/test/runner.coffee"]
  args.push(options.filter) if options.filter

  util.relay 'coffee', args

task 'package', 'Build the packaged annotator', ->
  invoke 'package:core'
  invoke 'package:plugins'
  invoke 'package:css'

task 'package:core', 'Build pkg/annotator.min.js', ->
  packager.build_coffee util.src_files(CORE), 'pkg/annotator.min.js'

task 'package:css', 'Build pkg/annotator.min.css', ->
  packager.build_css ['css/annotator.css'], 'pkg/annotator.min.css'

task 'package:plugins', 'Build pkg/annotator.<plugin_name>.min.js for all plugins', ->
  for p in PLUGINS
    packager.build_coffee util.src_files([p], 'plugin/'), "pkg/annotator.#{p}.min.js"

task 'package:kitchensink', 'Build pkg/annotator-full.min.js with Annotator and all plugins', ->
  plugins = PLUGINS.concat ['kitchensink']
  files = util.src_files(CORE).concat(util.src_files(plugins, 'plugin/'))
  packager.build_coffee files, 'pkg/annotator-full.min.js'

task 'package:clean', 'Clean package files', ->
  fs.unlink "pkg/annotator.min.css"
  fs.unlink "pkg/annotator.min.js"
  fs.unlink "pkg/annotator-full.min.js"
  for p in PLUGINS
    fs.unlink "pkg/annotator.#{p}.min.js"

option '-c', '--no-config', 'Do not embed config file'

task 'bookmarklet:prereqs', 'Compile the annotator for the bookmarklet', ->
  files = util.src_files(CORE).concat(util.src_files(BOOKMARKLET_PLUGINS, 'plugin/'))

  packager.build_coffee files, bookmarklet.annotator_js
  packager.build_css ['css/annotator.css'], bookmarklet.annotator_css, (css) ->
    css = css.replace(/(image\/png)?;|\}/g, (_, m) ->
      return _ if m == 'image/png'
      '!important' + _
    )

    fs.writeFile(bookmarklet.annotator_css, css)

task 'bookmarklet:build', 'Output bookmarklet source', (options) ->
  bookmarklet.build !options['no-config'], console.log

task 'bookmarklet:build_demo', 'Create the bookmarklet demo files', ->
  invoke 'bookmarklet:prereqs'

  html = fs.readFileSync(bookmarklet.tpl, 'utf8')

  bookmarklet.build true, (source) ->
    html = html.replace '__bookmarklet__', source.replace(/\$/g, '$$$$').replace(/"/g, '&quot;')
    fs.writeFile bookmarklet.demo, html
    console.log "Updated #{bookmarklet.demo}"

task 'bookmarklet:build_testrunner', 'Update bookmarklet test runner', ->
  invoke 'bookmarklet:prereqs'

  html = fs.readFileSync(bookmarklet.test_tpl, 'utf8')

  bookmarklet.build false, (source) ->
    html = html.replace '__bookmarklet__', source
    fs.writeFile bookmarklet.test_runner, html
    console.log "Updated #{bookmarklet.test_runner}"

task 'bookmarklet:watch', 'Watch the bookmarklet source for changes', ->
  options = {persistent: true, interval: 500}

  invoke 'bookmarklet:build_demo'
  console.log "Watching #{bookmarklet.source} for changes:"

  fs.watchFile bookmarklet.source, options, (curr, prev) ->
    return if curr.size is prev.size and curr.mtime.getTime() is prev.mtime.getTime()
    invoke 'bookmarklet:build_demo'

task 'i18n:update', 'Update the annotator.pot template', ->
  util.relay 'xgettext', ['-Lpython',
                          '-olocale/annotator.pot',
                          '-k_t', '-kgettext'].concat(
                            util.lib_files(CORE)
                          ).concat(
                            util.lib_files(PLUGINS, 'plugin/')
                          ), util.noisyPrint

#----------------------------------------------------------------------------

#
# Packager
#

packager =
  concat: (src, dest, callback) ->
    exec "cat #{src.join ' '} > #{dest}", callback

  concat_coffee: (src, dest, callback) ->
    exec "cat #{src.join ' '} | coffee -sp > #{dest}", callback

  compress: (src, type, callback) ->
    yc = require 'yui-compressor'

    yc.compile(src, { type: type }, callback)

  build_coffee: (src, dest, callback) ->
    packager.concat_coffee(src, dest, ->
      code = fs.readFileSync(dest, 'utf8')

      packager.compress(code, 'js', (result) ->
        fs.writeFileSync(dest, result)
        (callback or ->)(result)
      )
    )

  build_css: (src, dest, callback) ->
    packager.concat(src, dest, ->
      code = fs.readFileSync(dest, 'utf8')

      packager.compress(code, 'css', (result) ->
        result = packager.data_uri_ify(result)
        fs.writeFileSync(dest, result)
        (callback or ->)(result)
      )
    )

  data_uri_ify: (css) ->
    # NB: path to image is "src/..." because the CSS urls start with "../img"
    b64_str = (name) -> fs.readFileSync("src/#{name}.png").toString('base64')
    b64_url = (m...) -> "url('data:image/png;base64,#{b64_str(m[2])}')"

    return css.replace(/(url\(([^)]+)\.png\))/g, b64_url)

#
# Bookmarklet Tasks
#

bookmarklet =
  annotator_js:  "#{BOOKMARKLET_PATH}/pkg/annotator.min.js"
  annotator_css: "#{BOOKMARKLET_PATH}/pkg/annotator.min.css"
  source:        "#{BOOKMARKLET_PATH}/src/bookmarklet.js"
  config:        "#{BOOKMARKLET_PATH}/config.json"
  tpl:           "#{BOOKMARKLET_PATH}/template.html"
  demo:          "#{BOOKMARKLET_PATH}/demo.html"
  test_tpl:      "#{BOOKMARKLET_PATH}/test/template.html"
  test_runner:   "#{BOOKMARKLET_PATH}/test/runner.html"

  # Create the bookmarklet
  build: (embedConfig, callback) ->
    source = fs.readFileSync(bookmarklet.source, 'utf8')

    if arguments.length == 1
      callback = embedConfig
    else if embedConfig
      # Replace the __config__ placeholder with the JSON data.
      config = fs.readFileSync(bookmarklet.config, 'utf8')
      source = source.replace('__config__', config)

    packager.compress(source, 'js', callback)

#
# Utility functions
#

util =
  src_files: (names, prefix='') -> names.map (x) -> "src/#{prefix}#{x}.coffee"
  lib_files: (names, prefix='') -> names.map (x) -> "lib/#{prefix}#{x}.js"

  # relay: run child process relaying std{out,err} to this process
  relay: (cmd, args, stdoutPrint=print, stderrPrint=debug) ->
    handle = spawn cmd, args

    handle.stdout.on 'data', (data) -> stdoutPrint(data) if data
    handle.stderr.on 'data', (data) -> stderrPrint(data) if data

  noisyPrint: (data) ->
    print data
    if data.toString('utf8').indexOf('In') is 0
      exec 'afplay ~/.autotest.d/sound/sound_fx/red.mp3 2>&1 >/dev/null'

