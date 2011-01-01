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
      'annotationViewerShown': 'updateViewer',
      'annotationEditorShown': 'updateEditor',
      'annotationEditorHidden': 'clearEditor',
      'annotationEditorSubmit': 'setAnnotationTags'
    };
    function Tags(element, options) {
      this.setAnnotationTags = __bind(this.setAnnotationTags, this);;
      this.clearEditor = __bind(this.clearEditor, this);;
      this.updateEditor = __bind(this.updateEditor, this);;      Tags.__super__.constructor.apply(this, arguments);
      this.addEvents();
      this.tagSrc = "<input type='text' class='annotator-editor-tags' placeholder='tags&hellip;'>";
    }
    Tags.prototype.updateEditor = function(e, editorElement, annotation) {
      var controls;
      if (!this.tags) {
        controls = $(editorElement).find('.annotator-editor-controls');
        this.tags = $(this.tagSrc).insertBefore(controls).get(0);
      }
      if ((annotation != null ? annotation.tags : void 0) != null) {
        return $(this.tags).val(this.stringifyTags(annotation.tags));
      }
    };
    Tags.prototype.clearEditor = function(e, editorElement) {
      if (this.tags) {
        return $(this.tags).val('');
      }
    };
    Tags.prototype.setAnnotationTags = function(e, editorElement, annotation) {
      if (this.tags) {
        return annotation.tags = this.parseTags($(this.tags).val());
      }
    };
    Tags.prototype.parseTags = function(string) {
      return string.split(/\s+/);
    };
    Tags.prototype.stringifyTags = function(array) {
      return array.join(" ");
    };
    Tags.prototype.updateViewer = function(e, viewerElement, annotations) {
      var $textEl, annElements, i, tagStr, tags, _ref, _results;
      annElements = $(viewerElement).find('.annotator-ann');
      _results = [];
      for (i = 0, _ref = annElements.length; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
        tags = annotations[i].tags;
        tagStr = tags != null ? tags.join(", ") : void 0;
        $textEl = annElements.eq(i).find('.annotator-ann-text');
        _results.push(tagStr && tagStr !== "" ? $("<div class='annotator-ann-tags'>" + (tags.join(", ")) + "</div>").insertAfter($textEl) : void 0);
      }
      return _results;
    };
    return Tags;
  })();
}).call(this);
