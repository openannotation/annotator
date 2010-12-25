(function() {
  var $;
  $ = jQuery;
  $.fn.textNodes = function() {
    var getTextNodes;
    getTextNodes = function(node) {
      if (node.nodeType !== Node.TEXT_NODE) {
        return $(node).contents().map(function() {
          return getTextNodes(this);
        }).get();
      } else {
        return node;
      }
    };
    return this.map(function() {
      return _.flatten(getTextNodes(this));
    });
  };
  $.fn.xpath = function(relativeRoot) {
    var jq;
    jq = this.map(function() {
      var elem, idx, path;
      path = '';
      elem = this;
      while ((elem != null ? elem.nodeType : void 0) === Node.ELEMENT_NODE && elem !== relativeRoot) {
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
