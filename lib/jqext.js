// John Resig's Simple Javascript Inheritance.

// Inspired by base2 and Prototype
(function(){//{{{
  var initializing = false, fnTest = /xyz/.test(function(){xyz;}) ? (/\b_super\b/) : (/.*/);

  // The base Class implementation (does nothing)
  this.Class = function(){};
 
  // Create a new Class that inherits from this class
  Class.extend = function(prop) {
    var _super = this.prototype;
   
    // Instantiate a base class (but only create the instance,
    // don't run the init constructor)
    initializing = true;
    var prototype = new this();
    initializing = false;
   
    // Copy the properties over onto the new prototype
    for (var name in prop) {
      // Check if we're overwriting an existing function
      prototype[name] = typeof prop[name] == "function" &&
        typeof _super[name] == "function" && fnTest.test(prop[name]) ?
        (function(name, fn){
          return function() {
            var tmp = this._super;
           
            // Add a new ._super() method that is the same method
            // but on the super-class
            this._super = _super[name];
           
            // The method only need to be bound temporarily, so we
            // remove it when we're done executing
            var ret = fn.apply(this, arguments);       
            this._super = tmp;
           
            return ret;
          };
        })(name, prop[name]) :
        prop[name];
    }
   
    // The dummy class constructor
    function Class() {
      // All construction is actually done in the init method
      if ( !initializing && this.init )
        this.init.apply(this, arguments);
    }
   
    // Populate our constructed prototype object
    Class.prototype = prototype;
   
    // Enforce the constructor to be what we expect
    Class.constructor = Class;

    // And make this class extendable
    Class.extend = arguments.callee;
   
    return Class;
  };
})();//}}}

var DelegatorClass = Class.extend({
    events: {},
    
    init: function () {
        var __obj = this;
        
        $.each(this.events, function (sel, fn) {
            var ary = sel.split(' ');
            $(ary.slice(0, -1).join(' ')).live(ary.slice(-1)[0], function () {
                return __obj[fn].apply(__obj, arguments);
            });
        });
    }
});


(function($){
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
