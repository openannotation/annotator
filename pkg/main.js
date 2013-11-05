;(function (f) {
  // <script>
  var Annotator = null;
  if (typeof window !== 'undefined' && window.Annotator !== 'undefined') {
    Annotator = window.Annotator;
  }
  if (typeof global !== 'undefined' && global.Annotator !== 'undefined') {
    Annotator = global.Annotator;
  }
  if (typeof self !== 'undefined' && self.Annotator !== 'undefined') {
    Annotator = self.Annotator;
  }


  // RequireJS
  if (typeof define === "function" && define.amd) {
    define(['annotator/annotator'], f);
  }

  // CommonJS
  else if (typeof exports === "object") {
    module.exports = f(Annotator);
  }

  return Annotator;
})(function (Annotator) {
  return Annotator || require('annotator/annotator');
});
