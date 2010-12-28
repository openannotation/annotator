fs   = require 'fs'
path = require 'path'

getSpecFiles = (dir, pattern="^.+\.coffee$") ->
  specs = []
  dir = path.normalize dir
  matcher = new RegExp(pattern)

  if fs.statSync(dir).isFile() and dir.match(matcher)
    specs.push(dir)
  else
    for f in fs.readdirSync(dir)
      filename = dir + '/' + f
      if fs.statSync(filename).isFile() and filename.match(matcher)
        specs.push(filename)
      else if fs.statSync(filename).isDirectory()
        subfiles = getSpecFiles(filename, matcher)
        specs.push(subfiles...)

  specs

exports.getSpecFiles = getSpecFiles

exports.addFixtureHelpers = (sandbox, fixtureDir) ->
  helpers = {
    fix: -> sandbox.document.body

    getFixture: (fname) ->
      fs.readFileSync("#{fixtureDir}/#{fname}.html", 'utf8')

    addFixture: (fname) ->
      sandbox.jQuery(sandbox.getFixture(fname)).appendTo(sandbox.fix())

    clearFixtures: ->
      sandbox.jQuery(sandbox.fix()).empty()
  }

  for name, fn of helpers
    sandbox[name] = fn
