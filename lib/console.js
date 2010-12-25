(function() {
  var console, fn, functions, _i, _j, _len, _len2;
  functions = ["log", "debug", "info", "warn", "exception", "assert", "dir", "dirxml", "trace", "group", "groupEnd", "groupCollapsed", "time", "timeEnd", "profile", "profileEnd", "count", "clear", "table", "error", "notifyFirebug", "firebug", "userObjects"];
  if (typeof console != "undefined" && console !== null) {
    if (!(console.group != null)) {
      console.group = function(name) {
        return console.log("GROUP: ", name);
      };
    }
    if (!(console.groupCollapsed != null)) {
      console.groupCollapsed = console.group;
    }
    for (_i = 0, _len = functions.length; _i < _len; _i++) {
      fn = functions[_i];
      if (!(console[fn] != null)) {
        console[fn] = function() {
          return console.log("Not implemented: console." + name);
        };
      }
    }
  } else {
    console = {};
    for (_j = 0, _len2 = functions.length; _j < _len2; _j++) {
      fn = functions[_j];
      console[fn] = function() {};
    }
  }
}).call(this);
