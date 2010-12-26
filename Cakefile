{print} = require 'sys'
{spawn, exec} = require 'child_process'

task 'watch', 'Run development source watcher', ->
  code = spawn 'coffee', ['-w', '-c', '-o', 'lib/', 'src/']
  test = spawn 'coffee', ['-w', '-c', '-o', 'test/', 'test/src/']

  noisyPrint = (data) ->
    print data
    if data.toString('utf8').indexOf('In') is 0
      exec 'afplay ~/.autotest.d/sound/sound_fx/red.mp3 2>&1 >/dev/null'

  code.stdout.on 'data', noisyPrint
  test.stdout.on 'data', noisyPrint
