(function() {
  var $;
  $ = jQuery;
  this.Range = {};
  Range.sniff = function(r) {
    if (r.commonAncestorContainer != null) {
      return new Range.BrowserRange(r);
    } else if (r.start && typeof r.start === "string") {
      return new Range.SerializedRange(r);
    } else if (r.start && typeof r.start === "object") {
      return new Range.NormalizedRange(r);
    } else {
      console.error("Couldn't not sniff range type");
      return false;
    }
  };
  Range.BrowserRange = (function() {
    function BrowserRange(obj) {
      this.commonAncestorContainer = obj.commonAncestorContainer;
      this.startContainer = obj.startContainer;
      this.startOffset = obj.startOffset;
      this.endContainer = obj.endContainer;
      this.endOffset = obj.endOffset;
    }
    BrowserRange.prototype.normalize = function(root) {
      var it, node, nr, offset, p, r, _i, _len, _ref;
      if (this.tainted) {
        console.error("You may only call normalize() once on a BrowserRange!");
        return false;
      } else {
        this.tainted = true;
      }
      r = {};
      nr = {};
      _ref = ['start', 'end'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        node = this[p + 'Container'];
        offset = this[p + 'Offset'];
        if (node.nodeType === 1) {
          it = node.childNodes[offset];
          node = it || node.childNodes[offset - 1];
          while (node.nodeType !== 3) {
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
      nr.commonAncestor = this.commonAncestorContainer;
      while (nr.commonAncestor.nodeType !== 1) {
        nr.commonAncestor = nr.commonAncestor.parentNode;
      }
      return new Range.NormalizedRange(nr);
    };
    BrowserRange.prototype.serialize = function(root, ignoreSelector) {
      return this.normalize(root).serialize(root, ignoreSelector);
    };
    return BrowserRange;
  })();
  Range.NormalizedRange = (function() {
    function NormalizedRange(obj) {
      this.commonAncestor = obj.commonAncestor;
      this.start = obj.start;
      this.end = obj.end;
    }
    NormalizedRange.prototype.normalize = function(root) {
      return this;
    };
    NormalizedRange.prototype.serialize = function(root, ignoreSelector) {
      var end, serialization, start;
      serialization = function(node, isEnd) {
        var n, nodes, offset, origParent, textNodes, xpath, _i, _len;
        if (ignoreSelector) {
          origParent = $(node).parents(":not(" + ignoreSelector + ")").eq(0);
        } else {
          origParent = $(node).parent();
        }
        xpath = origParent.xpath(root)[0];
        textNodes = origParent.textNodes();
        nodes = textNodes.slice(0, textNodes.index(node));
        offset = 0;
        for (_i = 0, _len = nodes.length; _i < _len; _i++) {
          n = nodes[_i];
          offset += n.nodeValue.length;
        }
        if (isEnd) {
          return [xpath, offset + node.nodeValue.length];
        } else {
          return [xpath, offset];
        }
      };
      start = serialization(this.start);
      end = serialization(this.end, true);
      return new Range.SerializedRange({
        start: start[0],
        end: end[0],
        startOffset: start[1],
        endOffset: end[1]
      });
    };
    return NormalizedRange;
  })();
  Range.SerializedRange = (function() {
    function SerializedRange(obj) {
      this.start = obj.start;
      this.startOffset = obj.startOffset;
      this.end = obj.end;
      this.endOffset = obj.endOffset;
    }
    SerializedRange.prototype.normalize = function(root) {
      var cacXPath, common, endAncestry, i, length, nodeFromXPath, p, parentXPath, range, startAncestry, tn, _i, _j, _len, _len2, _ref, _ref2, _ref3;
      nodeFromXPath = function(xpath) {
        return document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
      };
      parentXPath = $(root).xpath()[0];
      startAncestry = this.start.split("/");
      endAncestry = this.end.split("/");
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
        _ref3 = $(nodeFromXPath(parentXPath + this[p])).textNodes();
        for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
          tn = _ref3[_j];
          if (length + tn.nodeValue.length >= this[p + 'Offset']) {
            range[p + 'Container'] = tn;
            range[p + 'Offset'] = this[p + 'Offset'] - length;
            break;
          } else {
            length += tn.nodeValue.length;
          }
        }
      }
      return new Range.BrowserRange(range).normalize(root);
    };
    SerializedRange.prototype.serialize = function(root, ignoreSelector) {
      return this.normalize(root).serialize(root, ignoreSelector);
    };
    SerializedRange.prototype.toObject = function() {
      return {
        start: this.start,
        startOffset: this.startOffset,
        end: this.end,
        endOffset: this.endOffset
      };
    };
    return SerializedRange;
  })();
}).call(this);
