sys = require 'sys'
{spawn} = require 'child_process'

task 'watch', 'Run development source watcher', ->
  code = spawn 'coffee', ['-w', '-c', '-o', 'lib/', 'src/']
  test = spawn 'coffee', ['-w', '-c', '-o', 'test/', 'test/src/']

  code.stdout.on 'data', (data) -> sys.print(data)
  code.stderr.on 'data', (data) -> sys.debug(data)
  test.stdout.on 'data', (data) -> sys.print(data)
  test.stderr.on 'data', (data) -> sys.debug(data)