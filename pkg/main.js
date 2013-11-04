;(function (f) {
  // CommonJS
  if (typeof exports === "object") {
    module.exports = f();

  // RequireJS
  } else if (typeof define === "function" && define.amd) {
    define(['annotator/annotator'], f);

  // <script>
  } else {
    if (typeof window !== "undefined") {
      window.Annotator = f();
    } else if (typeof global !== "undefined") {
      global.Annotator = f();
    } else if (typeof self !== "undefined") {
      self.Annotator = f();
    }
  }

})(function () {
  return require('annotator/annotator');
});
