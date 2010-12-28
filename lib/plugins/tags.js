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
  Annotator.Plugins.Tags = (function() {
    __extends(Tags, Delegator);
    Tags.prototype.events = {
      'annotationEditorShown': 'updateEditor'
    };
    function Tags(element, options) {
      this.updateEditor = __bind(this.updateEditor, this);;      Tags.__super__.constructor.apply(this, arguments);
      this.addEvents();
    }
    Tags.prototype.updateEditor = function(e, editorElement, annotation) {
      return $("<input type='text'>").appendTo(editorElement);
    };
    return Tags;
  })();
}).call(this);
