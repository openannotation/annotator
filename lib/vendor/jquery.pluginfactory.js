(function($) {

$.plugin = function(name, object) {
  // create a new plugin with the given name
  $.fn[name] = function(options) {
    
    var args = Array.prototype.slice.call(arguments, 1);
    return this.each(function() {
      
      // check the data() cache, if it's there we'll call the method requested
      var instance = $.data(this, name);
      if (instance) {
        options && instance[options].apply(instance, args);
      } else {
        // if a constructor was passed in...
        if (typeof object === 'function') instance = new object(options, this);
        // else an object was passed in
        else {
          // create a constructor out of it
          function F(){};
          F.prototype = object;
          instance = new F()
          instance.init(options,this);
        }
        
        $.data(this, name, instance);
      }
    });
  };
};

})(jQuery);