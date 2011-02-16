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

task 'test', 'Run tests', ->
  relay 'coffee', ["#{__dirname}/test/runner.coffee"]

task 'watch-bookmarklet', 'Watch the bookmarklet source for changes', ->

  root        = "contrib/bookmarklet"
  template    = "#{root}/dev.html"
  destination = "#{root}/demo.html"
  javascript  = "#{root}/src/bookmarklet.js"

  fs.watchFile javascript, {persistent: true, interval: 500}, (curr, prev) ->
      return if curr.size is prev.size and curr.mtime.getTime() is prev.mtime.getTime()

      exec "yuicompressor #{javascript}", (err, stdout, stderr) ->
        if stderr
          console.log "Unable to compress #{javascript}"
          console.log "Output from yuicompressor: \n", stderr
          return;

        throw err if err

        oneline = stdout.toString().replace(/"/g, '&quot;')
        fs.readFile template, (err, html) ->
          throw err if err
          
          html = html.toString().replace('{bookmarklet}', oneline)
          fs.writeFile destination, html, (err) ->
            throw err if err
            console.log "Updated #{destination}…"
