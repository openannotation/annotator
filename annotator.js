// John Resig's Simple Javascript Inheritance.
// Inspired by base2 and Prototype
(function(){
  var initializing = false, fnTest = /xyz/.test(function(){xyz;}) ? /\b_super\b/ : /.*/;

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
})();


// selection and range creation reference for the following code:
// http://www.quirksmode.org/dom/range_intro.html
var Annotator = Class.extend({
    init: function () { },
    
    update: function () {
        var span = $('<span class="hilight"></span>');
        this.range = this.getCurrentRange();
        
        this.range.surroundContents(span[0]);
    },

    // Return either a W3C Range object (first branch) or a Microsoft TextRange object,
    // dependent on browser support. NB: they are totally incompatible objects.
    getCurrentRange: function () {
        var sel, range;

        // These branches must stay in this order, as Opera supports both window.getSelection 
        // and document.selection, but we'd much rather interaction with the former.
        if (window.getSelection) {
            sel = window.getSelection();
            if (sel.getRangeAt) {
                return sel.getRangeAt(0);
            } else { // Safari <= 1.3
                var range = document.createRange();
                range.setStart(sel.anchorNode, sel.anchorOffset);
                range.setEnd(sel.focusNode, sel.focusOffset);
                return range;
            }
        } else if (document.selection) {
            return document.selection.createRange();
        }
    }
});

