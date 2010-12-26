(function() {
  var $;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  $ = jQuery;
  Annotator.Plugins.User = (function() {
    __extends(User, Delegator);
    User.prototype.events = {
      'annotationViewerShown': 'updateViewerWithUsers'
    };
    User.prototype.options = {
      display: function(elem, user) {
        return $(elem).append("<span class='user'>&ndash; " + user + "</span>");
      }
    };
    function User(element, options) {
      User.__super__.constructor.apply(this, arguments);
      this.addEvents();
    }
    User.prototype.updateViewerWithUsers = function(e, viewerElement, annotations) {
      var annDivs, d, user, _i, _len, _results;
      annDivs = $(viewerElement).find('div');
      _results = [];
      for (_i = 0, _len = annDivs.length; _i < _len; _i++) {
        d = annDivs[_i];
        user = $(d).data('annotation').user;
        _results.push(user ? this.options.display(d, user) : void 0);
      }
      return _results;
    };
    return User;
  })();
}).call(this);
