fs     = require 'fs'
sys    = require 'sys'
path   = require 'path'

jasmine = {}
jasmine.node = {}

class jasmine.node.ConsoleReporter
  constructor: (@callback) ->
    @log = []
    @columnCounter = 0
    @start = 0
    @elapsed = 0
    @colors = true
    @verbose = false
    @ansi =
      green: '\033[32m'
      red: '\033[31m'
      yellow: '\033[33m'
      none: '\033[0m'

  log: (str) ->

  reportSpecStarting: (runner) ->

  reportRunnerStarting: (runner) ->
    sys.puts('Started')
    @start = Number(new Date)

  reportSuiteResults: (suite) ->
    specResults = suite.results()
    path = []

    while (suite)
      path.unshift(suite.description)
      suite = suite.parentSuite

    description = path.join(' ')

    if (@verbose)
      @log.push('Spec ' + description)

    for spec in specResults.items_
      if (spec.failedCount > 0 && spec.description)
        if (!@verbose)
          @log.push(description)
        @log.push('  it ' + spec.description)
        for result in spec.items_
          @log.push('  ' + result.trace.stack + '\n')

  reportSpecResults: (spec) ->
    result = spec.results()
    msg = ''
    if result.passed()
      msg = if @colors then @ansi.green + '.' + @ansi.none else '.'
    else if result.skipped # TODO: Research why "result.skipped" returns false when "xit" is called on a spec?
      msg = if @colors then @ansi.yellow + '*' + @ansi.none else '*'
    else
      msg = if @colors then @ansi.red + 'F' + @ansi.none else 'F'

    sys.print(msg)
    return if @columnCounter++ < 50
    @columnCounter = 0
    sys.print('\n')

  reportRunnerResults: (runner) ->
    @elapsed = (Number(new Date) - @start) / 1000
    sys.puts('\n')
    for l in @log
      sys.puts(l)
    sys.puts('Finished in ' + @elapsed + ' seconds')

    summary = this.runnerResultsSummary(runner)
    if @colors
      if runner.results().failedCount is 0
        sys.puts(@ansi.green + summary + @ansi.none)
      else
        sys.puts(@ansi.red + summary + @ansi.none)
    else
      sys.puts(summary)

    @callback(runner, @log) if @callback

  runnerResultsSummary: (runner) ->
    results = runner.results()
    suites = runner.suites()

    plural = (n) -> if n is 1 then '' else 's'

    msg = ''
    msg += suites.length + ' test' + plural(suites.length) + ', '
    msg += results.totalCount + ' assertion' + plural(results.totalCount) + ', '
    msg += results.failedCount + ' failure' + plural(results.failedCount) + '\n'
    msg

exports.jasmine = jasmine
