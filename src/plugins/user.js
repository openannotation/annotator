(function($) {

Annotator.Plugins.User = DelegatorClass.extend({
  events: {
    'annotationViewerShown': 'updateViewerWithUsers'
  },

  init: function(options, element) {
    this.options = $.extend({
      // Define how to display the 'user' property of the annotation. By 
      // default assumes the value is string-coerceable, so just returns the 
      // value. If the user property were an object in and of itself, this 
      // could, for example, return u.name, or u.getName(), etc.
      //
      // @param elem The element representing the annotation.
      // @param user The value of the relevant annotation's "user" property.
      display: function(elem, user) {
        $(this).append('<span class="user">&ndash; ' +
                       self.options.display(user) +
                       '</span>');
      }
    }, options);

    this._super();
  },

  updateViewerWithUsers: function(e, viewerElement, annotations) {
    var self = this;

    $(viewerElement).find('p').each(function() {
      var user = $(this).data('annotation').user;
      if (user) {
        $(this).append('<span class="user">&ndash; ' +
                       self.options.display(user) +
                       '</span>');
      }
    });
  }
});

})(jQuery);
