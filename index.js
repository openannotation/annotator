var fs = require('fs');
var path = require('path');

var rfile = require('rfile');
var through = require('through');

var convert = require('convert-source-map');
var sourceMap = require('source-map');

var SourceMapConsumer = sourceMap.SourceMapConsumer;
var SourceMapGenerator = sourceMap.SourceMapGenerator;
var SourceNode = sourceMap.SourceNode;


// A browserify factory that correctly handles --standalone and --debug
function browserify (opts, xopts) {
  var browserify = require('browserify');
  var b = browserify(opts, xopts);
  var bundle = b.bundle.bind(b);
  var promise = null;

  b.bundle = function (options, cb) {
    if (typeof(options) == 'function') {
      cb = options;
      options = null;
    }
    options = options || {};

    // Strip the standalone option because we handle it ourselves. See above.
    var standalone = false;
    if (options.standalone && options.debug) {
      standalone = options.standalone;
      options = Object.create(options, {
        standalone: {
          enumerable: false,
          value: undefined
        }
      });
    }

    return bundle(options, function (err, result) {
      if (!cb) return;
      if (err) {
        cb(err);
      } else {
        if (standalone) {
          // Remove require= because browserify doesn't know to skip exports
          // when we wrap without passing along standalone.
          if (Object.keys(b.exports).length) result = result.slice(8);
          cb(null, umd(standalone, false, result, b._expose[b._entries[0]]));
        } else {
          cb(null, result);
        }
      }
    });
  };

  return b;
}


// A browserify factory that exposes the annotator namespace and then requires
// any other exposed modules. Use it to create standalone bundles for annotator
// extensions and plugins.
function include(opts, xopts) {
  var b = browserify(opts, xopts);
  var exposed = ['annotator'];
  var loader = through(expose);

  loader.pause();
  loader.write("module.exports = require('annotator');\n");

  b.external(path.resolve(__dirname, './lib/annotator'));
  b.require(loader, {basedir: __dirname, entry: true});
  b.require('./', {basedir: __dirname, expose: 'annotator'});
  b.transform(function (file) {
    return through(expose);
  });

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


// Prepend a chunk to a source file, consuming the supplied source map
// Returns {code::String, map::SourceMapGenerator}
function prepend(chunk, src, srcMap) {
  var srcNode = SourceNode.fromStringWithSourceMap(src, srcMap);
  srcNode.prepend(chunk);
  return srcNode.toStringWithSourceMap(srcMap);
}


// Browserify currently b0rks the source maps with --standalone and --debug.
// The umd module is the culprit. This provides that functionality in the
// meantime. It takes care of calling the main module as well.
function umd(name, cjs, src, mainModule) {
  var umd = require('umd');
  var srcMap = new SourceMapConsumer(convert.fromSource(src).toObject());

  mainModule = mainModule || 1;
  src = convert.removeComments(src).slice(0, -3);

  var output = prepend(umd.prelude(name) + 'return ', src, srcMap);

  return [
    output.code,
    '("' + mainModule + '")' + umd.postlude(name),
    convert.fromJSON(output.map.toString()).toComment(),
    ';'
  ].join('\n');
}


exports.browserify = browserify;
exports.include = include;
exports.prepend = prepend;
exports.umd = umd;
