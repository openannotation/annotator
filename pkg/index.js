module.exports = (
  (typeof Annotator == 'function') ? Annotator : require('./lib/annotator')
);
