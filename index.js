var through = require('through');


// Create browserify that exports the annotator namespace and then requires
// any other exposed modules. Use it to create standalone bundles for annotator
// extensions and plugins.
function include(browserify, opts, xopts) {
  var b = browserify(opts, xopts);
  var exposed = ['annotator'];
  var loader = through(expose);

  loader.pause();
  loader.write("module.exports = require('annotator');\n");

  b.add(loader);
  b.external('annotator');
  b.transform(function (file) {
    return through(expose);
  });

  // Browserify doesn't honor streams as entry points so we need to force it.
  b._entries.push(loader);

  return b;

  function expose(data) {
    this.queue(data);
    if (this === loader) return;

    var done = true;
    for (var m in b._mapped) {
      if (exposed.indexOf(m) == -1) {
        done = false;
        exposed.push(m);
        loader.write("require('" + m + "');\n");
      }
    }

    if (Object.keys(exposed).length == Object.keys(b._expose).length) {
      if (!done) {
        loader.resume();
        loader.end();
      }
    }
  }
}


function load() {
  if (typeof Annotator !== 'function') {
    var Annotator = require('annotator');
  }
}


exports.include = include;
