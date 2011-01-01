(function() {
  var $, Annotator, util;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  $ = jQuery;
  if (!(JSON && JSON.parse && JSON.stringify)) {
    console.error("Annotator requires JSON support: have you included lib/vendor/json2.js?");
  }
  util = {
    getGlobal: function() {
      return (function() {
        return this;
      })();
    },
    mousePosition: function(e, offsetEl) {
      var offset;
      offset = $(offsetEl).offset();
      return {
        top: e.pageY - offset.top,
        left: e.pageX - offset.left
      };
    }
  };
  Annotator = (function() {
    __extends(Annotator, Delegator);
    Annotator.prototype.events = {
      ".annotator-adder mousedown": "adderMousedown",
      ".annotator-hl mouseover": "highlightMouseover",
      ".annotator-hl mouseout": "startViewerHideTimer",
      ".annotator-viewer mouseover": "clearViewerHideTimer",
      ".annotator-viewer mouseout": "startViewerHideTimer",
      ".annotator-editor textarea keydown": "processEditorKeypress",
      ".annotator-editor form submit": "submitEditor",
      ".annotator-editor button.annotator-editor-save click": "submitEditor",
      ".annotator-editor button.annotator-editor-cancel click": "hideEditor",
      ".annotator-ann-controls .edit click": "controlEditClick",
      ".annotator-ann-controls .del click": "controlDeleteClick",
      "mouseup": "checkForEndSelection",
      "mousedown": "checkForStartSelection"
    };
    Annotator.prototype.dom = {
      adder: "<div class='annotator-adder'><a href='#'></a></div>",
      editor: "<div class='annotator-editor'>\n  <form>\n    <textarea></textarea>\n    <div class='annotator-editor-controls'>\n      <button type='submit' class='annotator-editor-save'>Save</button>\n      <button type='submit' class='annotator-editor-cancel'>Cancel</button>\n    </div>\n  <form>\n</div>",
      hl: "<span class='annotator-hl'></span>",
      viewer: "<div class='annotator-viewer'></div>"
    };
    Annotator.prototype.options = {};
    function Annotator(element, options) {
      this.controlDeleteClick = __bind(this.controlDeleteClick, this);;
      this.controlEditClick = __bind(this.controlEditClick, this);;
      this.adderMousedown = __bind(this.adderMousedown, this);;
      this.highlightMouseover = __bind(this.highlightMouseover, this);;
      this.clearViewerHideTimer = __bind(this.clearViewerHideTimer, this);;
      this.startViewerHideTimer = __bind(this.startViewerHideTimer, this);;
      this.showViewer = __bind(this.showViewer, this);;
      this.submitEditor = __bind(this.submitEditor, this);;
      this.processEditorKeypress = __bind(this.processEditorKeypress, this);;
      this.hideEditor = __bind(this.hideEditor, this);;
      this.showEditor = __bind(this.showEditor, this);;
      this.checkForEndSelection = __bind(this.checkForEndSelection, this);;
      this.checkForStartSelection = __bind(this.checkForStartSelection, this);;      var name, src, _ref;
      Annotator.__super__.constructor.apply(this, arguments);
      this.plugins = {};
      this.wrapper = $("<div></div>").addClass('annotator-wrapper');
      $(this.element).wrapInner(this.wrapper);
      this.wrapper = $(this.element).contents().get(0);
      _ref = this.dom;
      for (name in _ref) {
        src = _ref[name];
        this.dom[name] = $(src).hide().appendTo(this.wrapper);
      }
      this.addEvents();
    }
    Annotator.prototype.checkForStartSelection = function(e) {
      this.startViewerHideTimer();
      return this.mouseIsDown = true;
    };
    Annotator.prototype.checkForEndSelection = function(e) {
      var s, validSelection;
      this.mouseIsDown = false;
      if (this.ignoreMouseup) {
        return;
      }
      this.getSelection();
      s = this.selection;
      validSelection = (s != null ? s.rangeCount : void 0) > 0 && !s.isCollapsed;
      if (e && validSelection) {
        return this.dom.adder.css(util.mousePosition(e, this.wrapper)).show();
      } else {
        return this.dom.adder.hide();
      }
    };
    Annotator.prototype.getSelection = function() {
      var i;
      this.selection = util.getGlobal().getSelection();
      return this.selectedRanges = (function() {
        var _ref, _results;
        _results = [];
        for (i = 0, _ref = this.selection.rangeCount; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
          _results.push(this.selection.getRangeAt(i));
        }
        return _results;
      }).call(this);
    };
    Annotator.prototype.createAnnotation = function(annotation, fireEvents) {
      var a, normed, r, serialized, sniffed;
      if (fireEvents == null) {
        fireEvents = true;
      }
      a = annotation;
      a || (a = {});
      a.ranges || (a.ranges = this.selectedRanges);
      a.highlights || (a.highlights = []);
      a.ranges = (function() {
        var _i, _len, _ref, _results;
        _ref = a.ranges;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          r = _ref[_i];
          sniffed = Range.sniff(r);
          normed = sniffed.normalize(this.wrapper);
          _results.push(serialized = normed.serialize(this.wrapper, '.annotator-hl'));
        }
        return _results;
      }).call(this);
      a.highlights = this.highlightRange(normed);
      $(a.highlights).data('annotation', a);
      if (fireEvents) {
        $(this.element).trigger('beforeAnnotationCreated', [a]);
        $(this.element).trigger('annotationCreated', [a]);
      }
      return a;
    };
    Annotator.prototype.deleteAnnotation = function(annotation) {
      var h, _i, _len, _ref;
      _ref = annotation.highlights;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        h = _ref[_i];
        $(h).replaceWith($(h)[0].childNodes);
      }
      return $(this.element).trigger('annotationDeleted', [annotation]);
    };
    Annotator.prototype.updateAnnotation = function(annotation, data) {
      $.extend(annotation, data);
      $(this.element).trigger('beforeAnnotationUpdated', [annotation]);
      return $(this.element).trigger('annotationUpdated', [annotation]);
    };
    Annotator.prototype.loadAnnotations = function(annotations) {
      var loader, results;
      results = [];
      loader = __bind(function(annList) {
        var n, now, _i, _len;
        now = annList.splice(0, 10);
        for (_i = 0, _len = now.length; _i < _len; _i++) {
          n = now[_i];
          results.push(this.createAnnotation(n, false));
        }
        if (annList.length > 0) {
          return setTimeout((function() {
            return loader(annList);
          }), 100);
        }
      }, this);
      return loader(annotations);
    };
    Annotator.prototype.dumpAnnotations = function() {
      if (this.plugins['Store']) {
        return this.plugins['Store'].dumpAnnotations();
      } else {
        return console.warn("Can't dump annotations without Store plugin.");
      }
    };
    Annotator.prototype.highlightRange = function(normedRange) {
      var elemList, end, node, start, textNodes, wrapper, _ref;
      textNodes = $(normedRange.commonAncestor).textNodes();
      _ref = [textNodes.index(normedRange.start), textNodes.index(normedRange.end)], start = _ref[0], end = _ref[1];
      textNodes = textNodes.slice(start, (end + 1) || 9e9);
      return elemList = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = textNodes.length; _i < _len; _i++) {
          node = textNodes[_i];
          wrapper = this.dom.hl.clone().show();
          _results.push($(node).wrap(wrapper).parent().get(0));
        }
        return _results;
      }).call(this);
    };
    Annotator.prototype.addPlugin = function(name, options) {
      var klass, _base;
      if (this.plugins[name]) {
        console.error("You cannot have more than one instance of any plugin.");
      } else {
        klass = Annotator.Plugins[name];
        if (typeof klass === 'function') {
          this.plugins[name] = new klass(this.element, options);
          this.plugins[name].annotator = this;
          if (typeof (_base = this.plugins[name]).pluginInit === "function") {
            _base.pluginInit();
          }
        } else {
          console.error("Could not load " + name + " plugin. Have you included the appropriate <script> tag?");
        }
      }
      return this;
    };
    Annotator.prototype.showEditor = function(e, annotation) {
      if (annotation) {
        this.dom.editor.data('annotation', annotation);
        this.dom.editor.find('textarea').val(annotation.text);
      }
      this.dom.editor.css(util.mousePosition(e, this.wrapper)).show().find('textarea').focus();
      return $(this.element).trigger('annotationEditorShown', [this.dom.editor, annotation]);
    };
    Annotator.prototype.hideEditor = function(e) {
      if (e != null) {
        e.preventDefault();
      }
      this.dom.editor.data('annotation', null).hide().find('textarea').val('');
      $(this.element).trigger('annotationEditorHidden', [this.dom.editor]);
      return this.ignoreMouseup = false;
    };
    Annotator.prototype.processEditorKeypress = function(e) {
      if (e.keyCode === 27) {
        return this.hideEditor(e);
      } else if (e.keyCode === 13 && !e.shiftKey) {
        return this.submitEditor(e);
      }
    };
    Annotator.prototype.submitEditor = function(e) {
      var annotation, create, textarea;
      if (e != null) {
        e.preventDefault();
      }
      textarea = this.dom.editor.find('textarea');
      annotation = this.dom.editor.data('annotation');
      if (!annotation) {
        create = true;
        annotation = {};
      }
      $(this.element).trigger('annotationEditorSubmit', [this.dom.editor, annotation]);
      if (create) {
        annotation.text = textarea.val();
        this.createAnnotation(annotation);
      } else {
        this.updateAnnotation(annotation, {
          text: textarea.val()
        });
      }
      return this.hideEditor();
    };
    Annotator.prototype.showViewer = function(e, annotations) {
      var annot, controlsHTML, viewerclone, _i, _len;
      controlsHTML = "<span class=\"annotator-ann-controls\">\n  <a href=\"#\" class=\"edit\" alt=\"Edit\" title=\"Edit this annotation\">Edit</a>\n  <a href=\"#\" class=\"del\" alt=\"X\" title=\"Delete this annotation\">Delete</a>\n</span>";
      viewerclone = this.dom.viewer.clone().empty();
      for (_i = 0, _len = annotations.length; _i < _len; _i++) {
        annot = annotations[_i];
        $("<div class='annotator-ann'>\n  " + controlsHTML + "\n  <div class='annotator-ann-text'>\n    <p>" + annot.text + "</p>\n  </div>\n</div>").appendTo(viewerclone).data("annotation", annot);
      }
      viewerclone.css(util.mousePosition(e, this.wrapper)).replaceAll(this.dom.viewer).show();
      $(this.element).trigger('annotationViewerShown', [viewerclone.get(0), annotations]);
      return this.dom.viewer = viewerclone;
    };
    Annotator.prototype.startViewerHideTimer = function(e) {
      if (!this.viewerHideTimer) {
        return this.viewerHideTimer = setTimeout((function(ann) {
          return ann.dom.viewer.hide();
        }), 250, this);
      }
    };
    Annotator.prototype.clearViewerHideTimer = function() {
      clearTimeout(this.viewerHideTimer);
      return this.viewerHideTimer = false;
    };
    Annotator.prototype.highlightMouseover = function(e) {
      var annotations;
      this.clearViewerHideTimer();
      if (this.mouseIsDown) {
        return false;
      }
      annotations = $(e.target).parents('.annotator-hl').andSelf().map(function() {
        return $(this).data("annotation");
      });
      return this.showViewer(e, annotations);
    };
    Annotator.prototype.adderMousedown = function(e) {
      if (e != null) {
        e.preventDefault();
      }
      this.ignoreMouseup = true;
      this.dom.adder.hide();
      return this.showEditor(e);
    };
    Annotator.prototype.controlEditClick = function(e) {
      var annot, offset, pos;
      annot = $(e.target).parents('.annotator-ann');
      offset = $(this.dom.viewer).offset();
      pos = {
        pageY: offset.top,
        pageX: offset.left
      };
      this.dom.viewer.hide();
      this.showEditor(pos, annot.data("annotation"));
      return false;
    };
    Annotator.prototype.controlDeleteClick = function(e) {
      var annot;
      annot = $(e.target).parents('.annotator-ann');
      this.deleteAnnotation(annot.data("annotation"));
      annot.remove();
      if (!this.dom.viewer.is(':parent')) {
        this.dom.viewer.hide();
      }
      return false;
    };
    return Annotator;
  })();
  Annotator.Plugins = {};
  $.plugin('annotator', Annotator);
  this.Annotator = Annotator;
}).call(this);
