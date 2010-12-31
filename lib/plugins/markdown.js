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
  Annotator.Plugins.Markdown = (function() {
    __extends(Markdown, Delegator);
    Markdown.prototype.events = {
      'annotationViewerShown': 'updateViewer'
    };
    function Markdown(element, options) {
      this.updateViewer = __bind(this.updateViewer, this);;      if (typeof Showdown != "undefined" && Showdown !== null) {
        Markdown.__super__.constructor.apply(this, arguments);
        this.addEvents();
        this.converter = new Showdown.converter();
      } else {
        console.error("To use the Markdown plugin, you must include Showdown into the page first.");
      }
    }
    Markdown.prototype.updateViewer = function(e, viewerElement, annotations) {
      var ann, markdown, t, textContainers, _i, _len, _results;
      textContainers = $(viewerElement).find('.annotator-ann-text');
      _results = [];
      for (_i = 0, _len = textContainers.length; _i < _len; _i++) {
        t = textContainers[_i];
        ann = $(t).parent().data('annotation');
        markdown = this.converter.makeHtml(ann.text);
        _results.push($(t).html(markdown));
      }
      return _results;
    };
    return Markdown;
  })();
}).call(this);
