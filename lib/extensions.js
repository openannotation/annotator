(function($){
    this.DelegatorClass = Class.extend({
        events: {},

        init: function () {
            var __obj = this;
            $.each(this.events, function (sel, functionName) {
                var ary = sel.split(' ');
                __obj.addDelegatedEvent(ary.slice(0, -1).join(' '), ary.slice(-1)[0], functionName);
            });
        },

        addDelegatedEvent: function (selectorOrElement, event, functionName) {
            var __obj = this;

            this.element = this.element || document.body;

            $(this.element).bind(event, function (ev) {
                for(var el = ev.target; el !== __obj.element.parentNode; el = el.parentNode) {
                    if (el === selectorOrElement || $(el).is(selectorOrElement)) {
                        return __obj[functionName].apply(__obj, arguments);
                    }
                }
            });
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
            var isArray = function (object) {
                return object !== null && typeof object === "object" &&
                       'splice' in object && 'join' in object;
            };

            return $.inject(ary, [], function(array, value) {
                return array.concat(isArray(value) ? $.flatten(value) : value);
            });
        }
    });

    $.fn.textNodes = function () {
        function getTextNodes(node) {
            if (node.nodeType !== Node.TEXT_NODE) {
                var contents = $(node).contents().map(function () {
                    return getTextNodes(this);
                });
                return $.flatten(contents);
            } else {
                return [node];
            }
        }
        return this.map(function () {
            return getTextNodes(this);
        });
    };

    $.fn.xpath = function () {
        return this.map(function () {
            var path = '';
            for (var elem = this;
                 elem && elem.nodeType == Node.ELEMENT_NODE;
                 elem = elem.parentNode) {

                var idx = $(elem.parentNode).children(elem.tagName).index(elem) + 1;

                idx > 1 ? (idx='[' + idx + ']') : (idx = '');

                path = '/' + elem.tagName.toLowerCase() + idx + path;
            }
            return path;
        });
    };

})(jQuery);

// vim:fdm=marker:et:
