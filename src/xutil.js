(function() {
  var $, xUtil;

  $ = require('jquery');

  xUtil = {};

  xUtil.NodeTypes = {
    ELEMENT_NODE: 1,
    ATTRIBUTE_NODE: 2,
    TEXT_NODE: 3,
    CDATA_SECTION_NODE: 4,
    ENTITY_REFERENCE_NODE: 5,
    ENTITY_NODE: 6,
    PROCESSING_INSTRUCTION_NODE: 7,
    COMMENT_NODE: 8,
    DOCUMENT_NODE: 9,
    DOCUMENT_TYPE_NODE: 10,
    DOCUMENT_FRAGMENT_NODE: 11,
    NOTATION_NODE: 12
  };

  xUtil.getFirstTextNodeNotBefore = function(n) {
    var result;
    switch (n.nodeType) {
      case xUtil.NodeTypes.TEXT_NODE:
        return n;
      case xUtil.NodeTypes.ELEMENT_NODE:
        if (n.firstChild != null) {
          result = xUtil.getFirstTextNodeNotBefore(n.firstChild);
          if (result != null) {
            return result;
          }
        }
        break;
    }
    n = n.nextSibling;
    if (n != null) {
      return xUtil.getFirstTextNodeNotBefore(n);
    } else {
      return null;
    }
  };

  xUtil.getLastTextNodeUpTo = function(n) {
    var result;
    switch (n.nodeType) {
      case xUtil.NodeTypes.TEXT_NODE:
        return n;
      case xUtil.NodeTypes.ELEMENT_NODE:
        if (n.lastChild != null) {
          result = xUtil.getLastTextNodeUpTo(n.lastChild);
          if (result != null) {
            return result;
          }
        }
        break;
    }
    n = n.previousSibling;
    if (n != null) {
      return xUtil.getLastTextNodeUpTo(n);
    } else {
      return null;
    }
  };

  xUtil.getTextNodes = function(jq) {
    var getTextNodes;
    getTextNodes = function(node) {
      var nodes;
      if (node && node.nodeType !== xUtil.NodeTypes.TEXT_NODE) {
        nodes = [];
        if (node.nodeType !== xUtil.NodeTypes.COMMENT_NODE) {
          node = node.lastChild;
          while (node) {
            nodes.push(getTextNodes(node));
            node = node.previousSibling;
          }
        }
        return nodes.reverse();
     } else {
        return node;
      }
    };
    return jq.map(function() {
      return xUtil.flatten(getTextNodes(this));
    });
  };

  xUtil.getGlobal = function() {
    return (function() {
      return this;
    })();
  };

  xUtil.contains = function(parent, child) {
    var node;
    node = child;
    while (node != null) {
      if (node === parent) {
        return true;
      }
      node = node.parentNode;
    }
    return false;
  };

  xUtil.flatten = function(array) {
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
    return flatten(array);
  };

  module.exports = xUtil;

}).call(this);
