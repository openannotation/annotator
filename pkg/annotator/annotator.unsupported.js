/*
** Annotator v1.2.5
** https://github.com/okfn/annotator/
**
** Copyright 2012 Aron Carroll, Rufus Pollock, and Nick Stenning.
** Dual licensed under the MIT and GPLv3 licenses.
** https://github.com/okfn/annotator/blob/master/LICENSE
**
** Built at: 2012-06-22 12:25:37Z
*/

(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Annotator.Plugin.Unsupported = (function(_super) {

    __extends(Unsupported, _super);

    function Unsupported() {
      Unsupported.__super__.constructor.apply(this, arguments);
    }

    Unsupported.prototype.options = {
      message: Annotator._t("Sorry your current browser does not support the Annotator")
    };

    Unsupported.prototype.pluginInit = function() {
      var _this = this;
      if (!Annotator.supported()) {
        return $(function() {
          Annotator.showNotification(_this.options.message);
          if ((window.XMLHttpRequest === void 0) && (ActiveXObject !== void 0)) {
            return $('html').addClass('ie6');
          }
        });
      }
    };

    return Unsupported;

  })(Annotator.Plugin);

}).call(this);
