# Annotator will export itself globally when the built UMD modules are used in
# a legacy environment of simple script concatenation.
self = self if self?
self ?= global if global?
self ?= window if window?

# In order to build portable extension bundles that can be used with AMD and
# legacy script concatenation the plugins are built with this module exposed as
# 'annotator'.
Annotator = self?.Annotator

# This namespace is designed to adapt to AMD and legacy environments.
# In a pure AMD environment, Annotator may not be exported globally.
Annotator ?= if self?.define?.amd then self?.require('annotator')

# Note: when working in a CommonJS environment and bundling extensions in
# applications then plugin requirements should refer to the npm lib directory of
# the installed annotator package and avoid this altogether.
module.exports = Annotator
