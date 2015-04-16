// Main module: default UI
exports.main = require('./ui/main').main;

// Export submodules for browser environments
exports.adder = require('./ui/adder');
exports.editor = require('./ui/editor');
exports.filter = require('./ui/filter');
exports.highlighter = require('./ui/highlighter');
exports.markdown = require('./ui/markdown');
exports.tags = require('./ui/tags');
exports.textselector = require('./ui/textselector');
exports.viewer = require('./ui/viewer');
exports.widget = require('./ui/widget');
