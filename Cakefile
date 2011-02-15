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