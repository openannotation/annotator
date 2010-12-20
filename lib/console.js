// Stub the console when not available so that everything still works.
;(function () {
  var i, functions = ["log", "debug", "info", "warn", "exception", "assert", "dir", "dirxml", "trace", "group", "groupEnd", "groupCollapsed", "time", "timeEnd", "profile", "profileEnd", "count", "clear", "table", "error", "notifyFirebug", "firebug", "userObjects"]


  if (!("console" in this)) {
    this.console = {}
    for (i = 0; i < functions.length; i += 1) {
      this.console[functions[i]] = function () {}
    }
  } else {
    // Opera's console doesn't have a group function as of 2010-07-01
    if (!("group" in console)) {
      console.group = function (name) { console.log("GROUP: ", name) }
    }

    // Webkit's developer console has yet to implement groupCollapsed as of 2010-07-01
    if (!("groupCollapsed" in console)) {
      console.groupCollapsed = console.group
    }

    // Stub out any remaining functions
    for (i = 0; i < functions.length; i += 1) {
      var name = functions[i]
      if (!(name in console)) {
        console[name] = function () { console.log("Not implemented: console." + name) }
      }
    }
  }
})()