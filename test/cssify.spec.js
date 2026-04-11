"use strict";

var assert = require("assert");
var path = require("path");

var cssify = require("../tools/cssify");

describe("tools/cssify", function () {
    it("transforms CSS into a JS module on modern Node", function (done) {
        var transform = cssify(path.resolve(__dirname, "../css/annotator.css"));
        var output = "";

        transform.on("data", function (chunk) {
            output += chunk;
        });

        transform.on("error", done);

        transform.on("end", function () {
            assert.ok(output.indexOf("module.exports = ") === 0);
            assert.ok(output.indexOf(".annotator-") !== -1);
            done();
        });

        transform.write(".annotator-test { color: red; }");
        transform.end();
    });
});
