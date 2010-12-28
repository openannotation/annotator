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
  util = {
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
      "-adder mousedown": "adderMousedown",
      "-highlighter mouseover": "highlightMouseover",
      "-highlighter mouseout": "startViewerHideTimer",
      "-viewer mouseover": "viewerMouseover",
      "-viewer mouseout": "startViewerHideTimer",
      "-controls .edit click": "controlEditClick",
      "-controls .del click": "controlDeleteClick",
      "mouseup": "checkForEndSelection",
      "mousedown": "checkForStartSelection"
    };
    Annotator.prototype.options = {
      classPrefix: "annot",
      dom: {
        adder: "<div><a href='#'></a></div>",
        editor: "<div><textarea></textarea></div>",
        highlighter: "<span></span>",
        viewer: "<div></div>"
      }
    };
    function Annotator(element, options) {
      this.controlDeleteClick = __bind(this.controlDeleteClick, this);;
      this.controlEditClick = __bind(this.controlEditClick, this);;
      this.viewerMouseover = __bind(this.viewerMouseover, this);;
      this.adderMousedown = __bind(this.adderMousedown, this);;
      this.highlightMouseover = __bind(this.highlightMouseover, this);;
      this.clearViewerHideTimer = __bind(this.clearViewerHideTimer, this);;
      this.startViewerHideTimer = __bind(this.startViewerHideTimer, this);;
      this.showViewer = __bind(this.showViewer, this);;
      this.showEditor = __bind(this.showEditor, this);;
      this.checkForEndSelection = __bind(this.checkForEndSelection, this);;
      this.checkForStartSelection = __bind(this.checkForStartSelection, this);;      var k, name, src, v, _ref, _ref2;
      Annotator.__super__.constructor.apply(this, arguments);
      this.plugins = {};
      this.wrapper = $("<div></div>").addClass(this.componentClassname('wrapper'));
      $(this.element).wrapInner(this.wrapper);
      this.wrapper = $(this.element).contents().get(0);
      _ref = this.events;
      for (k in _ref) {
        v = _ref[k];
        if (k[0] === '-') {
          this.events['.' + this.options.classPrefix + k] = v;
          delete this.events[k];
        }
      }
      this.dom = {};
      _ref2 = this.options.dom;
      for (name in _ref2) {
        src = _ref2[name];
        this.dom[name] = $(src).addClass(this.componentClassname(name)).appendTo(this.wrapper).hide();
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
        this.ignoreMouseup = false;
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
      this.selection = window.getSelection();
      return this.selectedRanges = (function() {
        var _ref, _results;
        _results = [];
        for (i = 0, _ref = this.selection.rangeCount; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
          _results.push(this.selection.getRangeAt(i));
        }
        return _results;
      }).call(this);
    };
    Annotator.prototype.createAnnotation = function(annotation) {
      var a, normed, r, serialized;
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
          if (r.commonAncestorContainer != null) {
            normed = this.normRange(r);
            serialized = this.serializeRange(normed);
          } else if (r.start && typeof r.start === "string") {
            normed = this.deserializeRange(r);
            serialized = r;
          } else {
            normed = r;
            serialized = this.serializeRange(normed);
          }
          _results.push(serialized);
        }
        return _results;
      }).call(this);
      a.highlights = this.highlightRange(normed);
      $(a.highlights).data('annotation', a);
      $(this.element).trigger('annotationCreated', [a]);
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
      return $(this.element).trigger('annotationUpdated', [annotation]);
    };
    Annotator.prototype.loadAnnotations = function(annotations, callback) {
      var loader, results;
      results = [];
      loader = __bind(function(annList) {
        var n, now, _i, _len;
        now = annList.splice(0, 10);
        for (_i = 0, _len = now.length; _i < _len; _i++) {
          n = now[_i];
          results.push(this.createAnnotation(n));
        }
        if (annList.length > 0) {
          return setTimeout((function() {
            return loader(annList);
          }), 100);
        } else {
          if (callback) {
            return callback(results);
          }
        }
      }, this);
      return loader(annotations);
    };
    Annotator.prototype.normRange = function(range) {
      var it, node, nr, offset, p, r, _i, _len, _ref;
      r = {};
      nr = {};
      _ref = ['start', 'end'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        node = range[p + 'Container'];
        offset = range[p + 'Offset'];
        if (node.nodeType === Node.ELEMENT_NODE) {
          it = node.childNodes[offset];
          node = it || node.childNodes[offset - 1];
          while (node.nodeType !== Node.TEXT_NODE) {
            node = node.firstChild;
          }
          offset = it ? 0 : node.nodeValue.length;
        }
        r[p] = node;
        r[p + 'Offset'] = offset;
      }
      nr.start = r.startOffset > 0 ? r.start.splitText(r.startOffset) : r.start;
      if (r.start === r.end) {
        if ((r.endOffset - r.startOffset) < nr.start.nodeValue.length) {
          nr.start.splitText(r.endOffset - r.startOffset);
        }
        nr.end = nr.start;
      } else {
        if (r.endOffset < r.end.nodeValue.length) {
          r.end.splitText(r.endOffset);
        }
        nr.end = r.end;
      }
      nr.commonAncestor = range.commonAncestorContainer;
      while (nr.commonAncestor.nodeType !== Node.ELEMENT_NODE) {
        nr.commonAncestor = nr.commonAncestor.parentNode;
      }
      return nr;
    };
    Annotator.prototype.serializeRange = function(normedRange) {
      var end, serialization, start;
      serialization = __bind(function(node, isEnd) {
        var nodes, offset, origParent, textNodes, xpath;
        origParent = $(node).parents(":not(." + (this.componentClassname('highlighter')) + ")").eq(0);
        xpath = origParent.xpath(this.wrapper)[0];
        textNodes = origParent.textNodes();
        nodes = textNodes.slice(0, textNodes.index(node));
        offset = _(nodes).reduce((function(acc, tn) {
          return acc + tn.nodeValue.length;
        }), 0);
        if (isEnd) {
          return [xpath, offset + node.nodeValue.length];
        } else {
          return [xpath, offset];
        }
      }, this);
      start = serialization(normedRange.start);
      end = serialization(normedRange.end, true);
      return {
        start: start[0],
        end: end[0],
        startOffset: start[1],
        endOffset: end[1]
      };
    };
    Annotator.prototype.deserializeRange = function(serializedRange) {
      var cacXPath, common, endAncestry, i, length, nodeFromXPath, p, parentXPath, range, startAncestry, _i, _len, _ref, _ref2;
      nodeFromXPath = function(xpath) {
        return document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
      };
      parentXPath = $(this.wrapper).xpath()[0];
      startAncestry = serializedRange.start.split("/");
      endAncestry = serializedRange.end.split("/");
      common = [];
      range = {};
      for (i = 0, _ref = startAncestry.length; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
        if (startAncestry[i] === endAncestry[i]) {
          common.push(startAncestry[i]);
        } else {
          break;
        }
      }
      cacXPath = parentXPath + common.join("/");
      range.commonAncestorContainer = nodeFromXPath(cacXPath);
      if (!range.commonAncestorContainer) {
        console.error("Error deserializing range: can't find XPath '" + cacXPath + "'. Is this the right document?");
      }
      _ref2 = ['start', 'end'];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        p = _ref2[_i];
        length = 0;
        $(nodeFromXPath(parentXPath + serializedRange[p])).textNodes().each(function() {
          if (length + this.nodeValue.length >= serializedRange[p + 'Offset']) {
            range[p + 'Container'] = this;
            range[p + 'Offset'] = serializedRange[p + 'Offset'] - length;
            return false;
          } else {
            length += this.nodeValue.length;
            return true;
          }
        });
      }
      return this.normRange(range);
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
          wrapper = this.dom.highlighter.clone().show();
          _results.push($(node).wrap(wrapper).parent().get(0));
        }
        return _results;
      }).call(this);
    };
    Annotator.prototype.addPlugin = function(name, options) {
      var klass;
      if (this.plugins[name]) {
        return console.error("You cannot have more than one instance of any plugin.");
      } else {
        klass = Annotator.Plugins[name];
        if (typeof klass === 'function') {
          this.plugins[name] = new klass(this.element, options);
          return this.plugins[name].annotator = this;
        } else {
          return console.error("Could not load " + name + " plugin. Have you included the appropriate <script> tag?");
        }
      }
    };
    Annotator.prototype.componentClassname = function(name) {
      return this.options.classPrefix + '-' + name;
    };
    Annotator.prototype.showEditor = function(e, annotation) {
      var self;
      self = this;
      if (annotation) {
        this.dom.editor.find('textarea').val(annotation.text);
      }
      this.dom.editor.css(util.mousePosition(e, this.wrapper)).show().find('textarea').focus().bind('keydown', function(e) {
        if (e.keyCode === 27) {
          return $(this).val('').unbind().parent().hide();
        } else if (e.keyCode === 13 && !e.shiftKey) {
          $(this).unbind().parent().hide();
          if (annotation) {
            self.updateAnnotation(annotation, {
              text: $(this).val()
            });
          } else {
            self.createAnnotation({
              text: $(this).val()
            });
          }
          return $(this).val('');
        }
      }).bind('blur', function(e) {
        return $(this).val('').unbind().parent().hide();
      });
      return this.ignoreMouseup = true;
    };
    Annotator.prototype.showViewer = function(e, annotations) {
      var annot, controlsHTML, viewerclone, _i, _len;
      controlsHTML = "<span class=\"" + (this.componentClassname('controls')) + "\">\n  <a href=\"#\" class=\"edit\" alt=\"Edit\" title=\"Edit this annotation\">Edit</a>\n  <a href=\"#\" class=\"del\" alt=\"X\" title=\"Delete this annotation\">Delete</a>\n</span>";
      viewerclone = this.dom.viewer.clone().empty();
      for (_i = 0, _len = annotations.length; _i < _len; _i++) {
        annot = annotations[_i];
        $("<div>\n  <div class='" + this.options.classPrefix + "-text'>\n    <p>" + annot.text + "</p>\n  </div>" + controlsHTML + "\n</div>").appendTo(viewerclone).data("annotation", annot);
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
      annotations = $(e.target).parents('.' + this.componentClassname('highlighter')).andSelf().map(function() {
        return $(this).data("annotation");
      });
      return this.showViewer(e, annotations);
    };
    Annotator.prototype.adderMousedown = function(e) {
      this.dom.adder.hide();
      this.showEditor(e);
      return false;
    };
    Annotator.prototype.viewerMouseover = function(e) {
      return this.clearViewerHideTimer();
    };
    Annotator.prototype.controlEditClick = function(e) {
      var offset, para, pos;
      para = $(e.target).parents('p');
      offset = $(this.dom.viewer).offset();
      pos = {
        pageY: offset.top,
        pageX: offset.left
      };
      this.dom.viewer.hide();
      this.showEditor(pos, para.data("annotation"));
      return false;
    };
    Annotator.prototype.controlDeleteClick = function(e) {
      var para;
      para = $(e.target).parents('p');
      this.deleteAnnotation(para.data("annotation"));
      para.remove();
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
