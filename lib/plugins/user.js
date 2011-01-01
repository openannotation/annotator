(function() {
  var $;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
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
      'beforeAnnotationCreated': 'addUserToAnnotation',
      'annotationViewerShown': 'updateViewer'
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
    User.prototype.updateViewer = function(e, viewerElement, annotations) {
      var $controlEl, $textEl, annElements, i, user, _ref, _results;
      annElements = $(viewerElement).find('.annotator-ann');
      _results = [];
      for (i = 0, _ref = annElements.length; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
        user = annotations[i].user;
        $controlEl = annElements.eq(i).find('.annotator-ann-controls');
        $textEl = annElements.eq(i).find('.annotator-ann-text');
        _results.push(user ? ($("<div class='annotator-ann-user'>" + user + "</div>").insertAfter($textEl), this.user && this.user !== user ? $controlEl.hide() : $controlEl.show()) : $controlEl.show());
      }
      return _results;
    };
    return User;
  })();
}).call(this);
