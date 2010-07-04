(function($){
    this.DelegatorClass = Class.extend({
        events: {},

        init: function () {
            var self = this;
            $.each(this.events, function (sel, functionName) {
                var ary = sel.split(' ');
                self.addDelegatedEvent(ary.slice(0, -1).join(' '), ary.slice(-1)[0], functionName);
            });
        },

        addDelegatedEvent: function (selectorOrElement, event, functionName) {
            var self = this,
                closure = function (ev) {
                    return self[functionName].apply(self, arguments);
                }

            this.element = this.element || document.body;

            if (typeof(selectorOrElement) === 'string' &&
                selectorOrElement.replace(/\s+/g, '') === '') {
                selectorOrElement = this.element;
            }

            if (typeof(selectorOrElement) === 'string') {
                $(this.element).delegate(selectorOrElement, event, closure);
            } else {
                $(selectorOrElement).bind(event, closure);
            }
        }
    });


    $.extend({
        inject: function(object, acc, iterator) {
            $.each(object, function (idx, val) {
                acc = iterator(acc, val, idx);
            });
            return acc;
        },

        flatten: function(ary) {
            return $.inject(ary, [], function(array, value) {
                return array.concat($.isArray(value) ? $.flatten(value) : value);
            });
        }
    });

    $.fn.textNodes = function () {
        function getTextNodes(node) {
            if (node.nodeType !== Node.TEXT_NODE) {
                return $(node).contents().map(function () {
                    return getTextNodes(this);
                }).get();
            } else {
                return node;
            }
        }
        return this.map(function () {
            return $.flatten(getTextNodes(this));
        });
    };

    $.fn.xpath = function (relativeRoot) {
        return this.map(function () {
            var path = '';
            for (var elem = this;
                 elem && elem.nodeType == Node.ELEMENT_NODE && elem !== relativeRoot;
                 elem = elem.parentNode) {

                var idx = $(elem.parentNode).children(elem.tagName).index(elem) + 1;
                idx > 1 ? (idx='[' + idx + ']') : (idx = '');
                path = '/' + elem.tagName.toLowerCase() + idx + path;
            }
            return path;
        }).get();
    };

})(jQuery);

// vim:fdm=marker:et:
