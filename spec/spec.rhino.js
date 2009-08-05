// NB: Rhino tests not yet working. Need to pull in env.js.
load('lib/vendor/jquery-1.3.min.js')
load('spec/jspec/jspec.js')
load('spec/jspec/jspec.jquery.js')
load('lib/jqext.js')
load('lib/annotator.js')

JSpec
.exec('spec/delegatorclass_spec.js')
.exec('spec/annotator_spec.js')
.run({ formatter : JSpec.formatters.Terminal })
.report()
