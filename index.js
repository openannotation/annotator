var fs = require('fs');
var path = require('path');
var through = require('through');


/**
 * Populate the Annotator namespace by require()'ing any exposed plugins.
 *
 * Given a browserify bundle transform any module exposed as 'annotator'
 * by appending `require()` calls all other exposed modules in the bundle.
 *
 * @param {object} b - A browserify bundle.
 */
module.exports = function (b) {
  if (b[__filename]) return b;
  else b[__filename] = true;

  return b
    .transform(function (file) {
      if (b._mapped['annotator'] == file) {
        return through(null, function () {
          this.queue('\n');
          for (var m in b._mapped) {
            if (m == 'annotator') continue;
            this.queue("require('" + m + "');\n");
          }
          this.queue(null);
        });
      } else {
        return through();
      }
    })
  ;
}
