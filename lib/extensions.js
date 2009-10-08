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

            if (typeof(selectorOrElement) === 'string' &&
                selectorOrElement.replace(/\s+/g, '') === '') {
                selectorOrElement = this.element;
            }

            $(this.element).bind(event, function (ev) {
                for(var el = ev.target; el !== __obj.element.parentNode; el = el.parentNode) {
                    if (el === selectorOrElement || $(el).is(selectorOrElement)) {
                        return __obj[functionName].apply(__obj, arguments);
                    }
                }
                return null;
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
            return $.inject(ary, [], function(array, value) {
                return array.concat($.isArray(value) ? $.flatten(value) : value);
            });
        },

        // The native jQuery.param function is a bit weak. This is a better 
        // replacement.
        //
        // Serialize an array of form elements or a set of
        // key/values into a query string.
        param: function( a ) {
            var s = [ ];

            function add( key, value ) {
                s[ s.length ] = encodeURIComponent(key) + '=' + encodeURIComponent(value);
            }

            // If an array was passed in, assume that it is an array
            // of form elements
            if ( jQuery.isArray(a) || a.jquery ) {
                // Serialize the form elements
                jQuery.each( a, function(){ add( this.name, this.value ); });
                
            // Otherwise, assume that it's an object to be serialized 
            // 
            // If a property of the object is an array, we append multiple 
            // "key[]=arrayval"s to the query string.
            //
            // to see the behaviour when you pass an array of objects 
            // (Annotator does this) try the following in Firebug: 
            //
            //     decodeURI($.param({objArray: [{foo: 1, bar: 2}, {foo: 'a', bar: 'b'}]}))
            //
            // Although the result looks odd, it is correctly parsed by 
            // Rails/Sinatra's request params parser, provided each object has 
            // the same keys.
            } else {
                // Serialize the key/values
                function serialize( obj, path ) {
                    var key, kp;
                    for ( key in obj ) {
                        kp = path ? (path + '[' + ($.isArray(obj) ? '' : key) + ']') : key;
                        
                        if (typeof(obj[key]) === 'object') {
                            serialize( obj[key], kp );
                        } else {
                            add( kp, $.isFunction(obj[key]) ? obj[key]() : obj[key] );
                        }
                    }
                }

                serialize(a);
            }

            // Return the resulting serialization
            return s.join("&").replace(/%20/g, "+");
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
