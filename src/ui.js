// Main module: default UI
//exports.main = require('./ui/main').main;

// Export submodules for browser environments

exports.filter = require('./ui/filter');
exports.markdown = require('./ui/markdown');
exports.tags = require('./ui/tags');
exports.textselector = require('./ui/textselector');
exports.widget = require('./ui/widget');

//drug mention
exports.editor = require('./ui/editor');
exports.viewer = require('./ui/viewer');
exports.adder = require('./ui/adder');
exports.highlighter = require('./ui/highlighter');
exports.temphighlighter = require('./ui/temphighlighter');

//ddiPlugin
//exports.main = require('./ui/ddiPlugin/ddimain').main;
exports.ddieditor = require('./ui/ddiPlugin/ddieditor');
exports.ddiviewer = require('./ui/ddiPlugin/ddiviewer');
exports.ddiadder = require('./ui/ddiPlugin/ddiadder');
exports.ddihighlighter = require('./ui/ddiPlugin/ddihighlighter');


//dbmi main
exports.dbmimain = require('./ui/dbmimain').main;