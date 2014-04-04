/**
 * Given a browserify bundle, set the 'annotator' module to be external and
 * provide the namespace shim in its place. This pattern makes it easy for
 * plugin authors to create UMD bundles:
 *
 *   $ browserify foo.js -p annotator --standalone Annotator.Plugin.Foo
 *
 * @param {object} b - A browserify bundle.
 */
module.exports = function (b) {
  return b
    .external('annotator')
    .require('annotator/lib/namespace', {expose: 'annotator'})
  ;
}
