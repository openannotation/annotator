(function() {
  var $;
  $ = jQuery;
  Array.prototype.flatten = function() {
    var flatten;
    flatten = function(ary) {
      var el, flat, _i, _len;
      flat = [];
      for (_i = 0, _len = ary.length; _i < _len; _i++) {
        el = ary[_i];
        flat = flat.concat(el && $.isArray(el) ? flatten(el) : el);
      }
      return flat;
    };
    return flatten(this);
  };
  $.fn.textNodes = function() {
    var getTextNodes;
    getTextNodes = function(node) {
      var n, _i, _len, _ref, _results;
      if (node && node.nodeType !== 3) {
        _ref = $(node).contents().get();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          n = _ref[_i];
          _results.push(getTextNodes(n));
        }
        return _results;
      } else {
        return node;
      }
    };
    return this.map(function() {
      return getTextNodes(this).flatten();
    });
  };
  $.fn.xpath = function(relativeRoot) {
    var jq;
    jq = this.map(function() {
      var elem, idx, path;
      path = '';
      elem = this;
      while (elem && elem.nodeType === 1 && elem !== relativeRoot) {
        idx = $(elem.parentNode).children(elem.tagName).index(elem) + 1;
        idx = idx > 1 ? "[" + idx + "]" : "";
        path = "/" + elem.tagName.toLowerCase() + idx + path;
        elem = elem.parentNode;
      }
      return path;
    });
    return jq.get();
  };
}).call(this);
