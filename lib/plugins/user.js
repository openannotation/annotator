(function() {
  var $;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  $ = jQuery;
  Annotator.Plugins.User = (function() {
    __extends(User, Delegator);
    User.prototype.events = {
      'beforeAnnotationCreated': 'addUserToAnnotation',
      'annotationViewerShown': 'updateViewer'
    };
    User.prototype.options = {
      userId: function(user) {
        return user;
      },
      userString: function(user) {
        return user;
      },
      userGroups: function(user) {
        return ['public'];
      }
    };
    function User(element, options) {
      this.updateViewer = __bind(this.updateViewer, this);;
      this.addUserToAnnotation = __bind(this.addUserToAnnotation, this);;      User.__super__.constructor.apply(this, arguments);
      this.addEvents();
    }
    User.prototype.setUser = function(userid) {
      return this.user = userid;
    };
    User.prototype.addUserToAnnotation = function(e, annotation) {
      if (this.user && annotation) {
        return annotation.user = this.user;
      }
    };
    User.prototype.authorise = function(action, annotation) {
      var g, groups, p, u, _i, _len, _ref, _ref2;
      if (p = annotation.permissions) {
        if (!action || !p[action]) {
          return true;
        } else {
          if (_ref = "user:" + (this.options.userId(this.user)), __indexOf.call(p[action], _ref) >= 0) {
            return true;
          } else if (groups = this.options.userGroups(this.user)) {
            for (_i = 0, _len = groups.length; _i < _len; _i++) {
              g = groups[_i];
              if (_ref2 = "group:" + g, __indexOf.call(p[action], _ref2) >= 0) {
                return true;
              }
            }
            return false;
          }
        }
      } else if (u = annotation.user) {
        if (this.user && this.options.userId(this.user) === u) {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    };
    User.prototype.updateViewer = function(e, viewerElement, annotations) {
      var $controlEl, $deleteEl, $textEl, $updateEl, annElements, i, u, _ref, _results;
      annElements = $(viewerElement).find('.annotator-ann');
      _results = [];
      for (i = 0, _ref = annElements.length; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
        $controlEl = annElements.eq(i).find('.annotator-ann-controls');
        $textEl = annElements.eq(i).find('.annotator-ann-text');
        if (u = annotations[i].user) {
          $("<div class='annotator-ann-user'>" + (this.options.userString(u)) + "</div>").insertAfter($textEl);
        }
        _results.push("permissions" in annotations[i] ? ($controlEl.show(), $updateEl = $controlEl.find('.edit'), $deleteEl = $controlEl.find('.delete'), this.authorise('update', annotations[i]) ? $updateEl.show() : $updateEl.hide(), this.authorise('delete', annotations[i]) ? $deleteEl.show() : $deleteEl.hide()) : "user" in annotations[i] ? this.authorise(null, annotations[i]) ? $controlEl.children().andSelf().show() : $controlEl.hide() : $controlEl.children().andSelf().show());
      }
      return _results;
    };
    return User;
  })();
}).call(this);
