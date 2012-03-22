fs   = require 'fs'

{print} = require 'util'
{exec}  = require 'child_process'

FFI  = require 'node-ffi'
libc = new FFI.Library(null, "system": ["int32", ["string"]])
run  = libc.system

COFFEE = "`npm bin`/coffee"
UGLIFY_JS = "`npm bin`/uglifyjs"
UGLIFY_CSS = "`npm bin`/uglifycss"

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
          , 'annotateitpermissions'
          ]

BOOKMARKLET_PATH = 'contrib/bookmarklet'
BOOKMARKLET_PLUGINS = ['auth', 'store', 'permissions', 'annotateitpermissions', 'unsupported', 'tags']

task 'watch', 'Run development source watcher', ->
  run "#{COFFEE} --watch --bare --compile --output #{__dirname}/lib #{__dirname}/src"

task "serve", "Serve the current directory", ->
  run "python -m SimpleHTTPServer 8000"

task "test", "Open the test suite in the browser", ->
  run "open http://localhost:8000/test/runner.html"

task "test:phantom", "Open the test suite in the browser", ->
  run "phantomjs test/runner.coffee http://localhost:8000/test/runner.html"

option "", "--no-minify", "Do not minify built scripts with `cake package`"
task 'package', 'Build the packaged annotator', ->
  invoke 'package:core'
  invoke 'package:plugins'
  invoke 'package:css'

task 'package:core', 'Build pkg/annotator.min.js', (options) ->
  packager.build_coffee util.src_files(CORE), !options['no-minify'], (output) ->
    fs.writeFile 'pkg/annotator.min.js', output

task 'package:css', 'Build pkg/annotator.min.css', (options) ->
  packager.build_css ['css/annotator.css'], !options['no-minify'], (output) ->
    fs.writeFile 'pkg/annotator.min.css', output

task 'package:plugins', 'Build pkg/annotator.<plugin_name>.min.js for all plugins', (options) ->
  make_callback = (pname) ->
    (output) -> fs.writeFile "pkg/annotator.#{pname}.min.js", output

  for p in PLUGINS
    packager.build_coffee util.src_files([p], 'plugin/'), !options['no-minify'], make_callback(p)

task 'package:kitchensink', 'Build pkg/annotator-full.min.js with Annotator and all plugins', (options) ->
  plugins = PLUGINS.concat ['kitchensink']
  files = util.src_files(CORE).concat(util.src_files(plugins, 'plugin/'))
  packager.build_coffee files, !options['no-minify'], (output) ->
    fs.writeFile 'pkg/annotator-full.min.js', output

task 'package:clean', 'Clean package files', ->
  fs.unlink "pkg/annotator.min.css"
  fs.unlink "pkg/annotator.min.js"
  fs.unlink "pkg/annotator-full.min.js"
  for p in PLUGINS
    fs.unlink "pkg/annotator.#{p}.min.js"

option '-c', '--no-config', 'Do not embed config file'

task 'bookmarklet:prereqs', 'Compile the annotator for the bookmarklet', (options) ->
  files = util.src_files(CORE).concat(util.src_files(BOOKMARKLET_PLUGINS, 'plugin/'))

  packager.build_coffee files, !options['no-minify'], (output) ->
    fs.writeFile bookmarklet.annotator_js, output

  packager.build_css ['css/annotator.css'], !options['no-minify'], (css) ->
    css = css.replace(/(image\/png)?;|\}/g, (_, m) ->
      return _ if m == 'image/png'
      '!important' + _
    )

    fs.writeFile bookmarklet.annotator_css, css

task 'bookmarklet:build', 'Output bookmarklet source', (options) ->
  bookmarklet.build !options['no-config'], (output) -> print(output)

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

task 'bookmarklet:upload', 'Upload bookmarklet source files to S3', ->
  invoke 'bookmarklet:prereqs'
  console.log("Uploading bookmarklet source files."
              "Don't expect this to work unless you have `s3cmd` and have configured it"
              "for access to the OKF's S3 account.")
  run "s3cmd --acl-public sync contrib/bookmarklet/pkg/*.{js,css} s3://assets.annotateit.org/bookmarklet/"

task 'i18n:update', 'Update the annotator.pot template', ->
  fileList = []
  fileList = fileList.concat util.lib_files(CORE)
  fileList = fileList.concat util.lib_files(PLUGINS, 'plugin/')

  run "xgettext -Lpython -olocale/annotator.pot -k_t -kgettext #{fileList.join(" ")}"

#----------------------------------------------------------------------------

#
# Packager
#

packager =
  build_coffee: (src, minify=true, callback=(->)) ->
    min = if minify then UGLIFY_JS else 'cat'
    cmd = "cat #{src.join ' '} | #{COFFEE} --stdio --print | #{min}"

    exec cmd, (e, stdout, stderr) ->
      throw e if e
      callback(stdout)

  build_css: (src, minify=true, callback=(->)) ->
    min = if minify then UGLIFY_CSS else 'cat'
    cmd = "#{min} #{src.join ' '}"

    exec cmd, (e, stdout, stderr) ->
      throw e if e
      callback(packager.data_uri_ify(stdout))

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

    proc = exec UGLIFY_JS, (e, stdout, stderr) ->
      throw e if e
      callback(stdout)

    proc.stdin.end(source)

#
# Utility functions
#

util =
  src_files: (names, prefix='') -> names.map (x) -> "src/#{prefix}#{x}.coffee"
  lib_files: (names, prefix='') -> names.map (x) -> "lib/#{prefix}#{x}.js"

