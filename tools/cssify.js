"use strict";

var path = require('path');

var EnhanceCSS = require('enhance-css');
var CleanCSS = require('clean-css');
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
            var clean = new CleanCSS();

            css = enhance.process(css).embedded.plain;
            css = clean.minify(css).styles;

            var body = "module.exports = " + JSON.stringify(css);

            this.queue(body);
            this.queue(null);
        }
    );
};
