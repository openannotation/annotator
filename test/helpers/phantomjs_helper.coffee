print = (msg, newline=true) ->
  if newline
    console.log(msg)
  else
    console.log(msg + '%%') # Append "%%" to signal direct write to STDOUT

class this.jasmine.PhantomJSReporter
  constructor: (@callback, @colors=true) ->
    @logger = []
    @start = 0
    @elapsed = 0
    @ansi =
      green: '\033[32m'
      red: '\033[31m'
      yellow: '\033[33m'
      none: '\033[0m'

  log: (str) ->

  reportSpecStarting: (runner) ->

  reportRunnerStarting: (runner) ->
    print('Started')
    @start = Number(new Date)

  reportSuiteResults: (suite) ->
    specResults = suite.results()

    path = []

    while (suite)
      path.unshift(suite.description)
      suite = suite.parentSuite

    description = path.join(' ')

    for spec in specResults.items_
      if (spec.failedCount > 0 && spec.description)
        @logger.push('\n' + description)
        @logger.push('  "it ' + spec.description + '"')
        for result in spec.items_
          if not result.passed_
            @logger.push('    ' + result.message)

  reportSpecResults: (spec) ->
    result = spec.results()

    if result.passed()
      msg = if @colors then @ansi.green + '.' + @ansi.none else '.'
    else if result.skipped # TODO: Research why "result.skipped" returns false when "xit" is called on a spec?
      msg = if @colors then @ansi.yellow + '*' + @ansi.none else '*'
    else
      msg = if @colors then @ansi.red + 'F' + @ansi.none else 'F'

    print(msg, false)

  reportRunnerResults: (runner) ->
    @elapsed = (Number(new Date) - @start) / 1000
    print('')
    for l in @logger
      print(l)
    print('\nFinished in ' + @elapsed + ' seconds')

    summary = this.runnerResultsSummary(runner)
    if @colors
      if runner.results().failedCount is 0
        print(@ansi.green + summary + @ansi.none)
      else
        print(@ansi.red + summary + @ansi.none)
    else
      print(summary)

    print('phantom:testsComplete:' + runner.results().failedCount)
    @callback(runner, @logger) if @callback

  runnerResultsSummary: (runner) ->
    results = runner.results()
    specs = runner.specs()

    plural = (n) -> if n is 1 then '' else 's'

    msg = ''
    msg += specs.length + ' spec' + plural(specs.length) + ', '
    msg += results.totalCount + ' assertion' + plural(results.totalCount) + ', '
    msg += results.failedCount + ' failure' + plural(results.failedCount)
    msg
