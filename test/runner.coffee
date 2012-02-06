specutil  = require './lib/specutil'
{Sandbox} = require './lib/sandbox'
{jasmine} = require './lib/jasmine'

ROOT_DIR     = __dirname + '/..'
SPEC_DIR     = ROOT_DIR + '/test/spec'
FIXTURES_DIR = ROOT_DIR + '/test/fixtures'

# Create new browser/document sandbox
s = new Sandbox(ROOT_DIR)

s.require 'lib/vendor/jquery.js'
s.require 'lib/vendor/json2.js'
s.require 'lib/vendor/showdown.js'

# Add fixture helpers
specutil.addFixtureHelpers(s.window, FIXTURES_DIR)

# Require jasmine test library
s.require 'lib/vendor/jasmine/jasmine.js'
# Require jasmine jquery helpers
s.require 'lib/vendor/jasmine-jquery.js'

# Patch in a vendor XPath implementation until jsdom has one
s.require 'lib/vendor/xpath.js'

# In a word: aaarrgrgh.
s.window.getSelection = -> "Node selection"

s.require 'lib/extensions.js'
s.require 'lib/class.js'
s.require 'lib/range.js'
s.require 'lib/annotator.js'
s.require 'lib/widget.js'
s.require 'lib/viewer.js'
s.require 'lib/editor.js'
s.require 'lib/notification.js'
s.require 'lib/plugin/permissions.js'
s.require 'lib/plugin/store.js'
s.require 'lib/plugin/auth.js'
s.require 'lib/plugin/markdown.js'
s.require 'lib/plugin/tags.js'
s.require 'lib/plugin/filter.js'
s.require 'lib/plugin/unsupported.js'
s.require 'lib/plugin/kitchensink.js'

s.require 'test/spec_helper.coffee'

# List of spec files to require
specFiles = specutil.getSpecFiles(SPEC_DIR)

# Really simple filtering. Args on commandline are used to filter specs that get
# run.
filters = process.argv[2..-1]
if filters.length > 0
  matched = filters.map (filter) ->
    specFiles.filter (name) ->
      name.indexOf(filter) > 0

  specFiles = matched.reduce( ((all, x) -> all.concat(x)), [] )

# Require specs
for specFile in specFiles
  s.require(specFile)

runnerFinished = (runner, log) ->
  # console.log("As of 2011-06-29, any failures you see should *not* be occurring. Please report them at http://github.com/okfn/annotator/issues.")
  console.log("As of 2012-02-06, you could well be seeing up to 35 failures, due to what looks like a bug in jsdom. Sorry about that.")

reporter = new jasmine.node.ConsoleReporter(runnerFinished, colors=true, verbose=false)

s.window.jasmine.getEnv().addReporter(reporter)
s.window.jasmine.getEnv().execute()

