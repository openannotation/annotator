"use strict";

var path = require('path');

var EnhanceCSS = require('enhance-css');
var through = require('through');


module.exports = function (filename) {
    if (!/\.css$/i.test(filename)) {
        return through();
    }

    var css = "";

    return through(
        function (chunk) {
            css += chunk;
        },
        function () {
            var enhance = new EnhanceCSS({
                rootPath: path.dirname(filename)
            });

            css = enhance.process(css).embedded.plain;

            // clean-css 3.x crashes on modern Node because it relies on
            // util.isRegExp(). Keep the build working by treating minification
            // as an optional optimization rather than a hard requirement.
            try {
                var CleanCSS = require('clean-css');
                css = new CleanCSS().minify(css).styles;
            } catch (err) {}

            var body = "module.exports = " + JSON.stringify(css);

            this.queue(body);
            this.queue(null);
        }
    );
};
