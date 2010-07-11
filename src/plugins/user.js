(function($){

Annotator.Plugins.User = DelegatorClass.extend({
    events: {
        'annotationViewerShown': 'updateViewerWithUsers'
    },

    init: function (options, element) {
        this.options = $.extend({
            // Define how to display the
            display: function (u) { return u; }
        }, options);

        this._super();
    },

    updateViewerWithUsers: function (e, viewerElement, annotations) {
        var self = this;

        $(viewerElement).find('p').each(function () {
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
