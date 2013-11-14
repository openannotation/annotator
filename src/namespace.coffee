# In order to build portable extension bundles that can be used with AMD and
# script concatenation plugins are built with this module as 'annotator'.

# Annotator will export itself globally when the built UMD modules are used in
# a legacy environment of simple script concatenation.
self = self if self?
self ?= global if global?
self ?= window if window?
Annotator = self?.Annotator

# In a pure AMD environment, Annotator may not be exported globally.
Annotator ?= if self?.define?.amd then self?.require('annotator')

# Note: when working in a CommonJS environment and bundling requirements into
# applications then require calls should refer to modules from the npm lib
# directory of annotator package and avoid this altogether.
module.exports = Annotator
