(function($){

this.AnnotationStore = DelegatorClass.extend({
    events: {
        'annotationCreated': 'annotationCreated',
        'annotationDeleted': 'annotationDeleted',
        'annotationUpdated': 'annotationUpdated'
    },

    init: function (options, element) {
        this.options = $.extend({
            prefix: '/store/annotations',
            annotator: $(element).data('annotator'),
            annotationData: {},
            urls: {
               'create': '',     // POST
               'read': '/:id',   // GET
               'update': '/:id', // POST/[PUT]
               'destroy': '/:id' // DELETE
            }
        }, options);

        // If the element on which we're instantiated doesn't already have an
        // annotator instance, create one.
        if (!this.options.annotator) {
            $(element).annotator();
            this.options.annotator = $(element).data('annotator');
        }

        this.element = element;
        this.annotations = [];

        this.loadAnnotations();

        this._super();
    },

    annotationCreated: function (e, annotation) {
        var self = this;

        // Pre-register the annotation so as to save the list of highlight
        // elements.
        if ($.inArray(annotation, this.annotations) === -1) {
            this.registerAnnotation(annotation);
            $.ajax({
                url: this._urlFor('create'),
                data: this._dataFor(annotation),
                dataType: 'jsonp',
                type: 'POST',
                success: function (data) {
                    // Update with (e.g.) ID from server.
                    if (!("id" in data)) { console.warn("Warning: No ID returned from server for annotation ", annotation); }
                    self.updateAnnotation(annotation, data);
                },
                error: function () { self.handleBackendError.apply(self, arguments); }
            });
        } else {
            // This is called to update annotations created at load time with
            // the highlight elements created by Annotator.
            self.updateAnnotation(annotation, {});
        }
    },

    annotationDeleted: function (e, annotation) {
        var self = this;

        if ($.inArray(annotation, this.annotations) !== -1) {
            $.ajax({
                url: this._urlFor('destroy', annotation.id),
                type: 'DELETE',
                success: function () { self.unregisterAnnotation(annotation); },
                error: function () { self.handleBackendError.apply(self, arguments); }
            });
        }
    },

    annotationUpdated: function (e, annotation) {
        var self = this;

        if ($.inArray(annotation, this.annotations) !== -1) {
            $.ajax({
                url: this._urlFor('update', annotation.id),
                type: 'POST',
                data: this._dataFor(annotation),
                dataType: 'jsonp',
                success: function () { self.updateAnnotation(annotation); },
                error: function () { self.handleBackendError.apply(self, arguments); }
            });
        }
    },

    // NB: registerAnnotation and unregisterAnnotation do no error-checking/
    // duplication avoidance of their own. Use with care.
    registerAnnotation: function (annotation) {
        this.annotations.push(annotation);
    },

    unregisterAnnotation: function (annotation) {
        this.annotations.splice(this.annotations.indexOf(annotation), 1);
    },

    updateAnnotation: function (annotation, data) {
        if ($.inArray(annotation, this.annotations) === -1) {
            console.error("Trying to update unregistered annotation!");
        } else {
            $.extend(annotation, data);
        }

        // Update the elements with our copies of the annotation objects (e.g.
        // with ids from the server).
        $(annotation.highlights).data('annotation', annotation);
    },

    loadAnnotation: function (id) {
        // NB: null id loads all annotations.
        var self = this;
        $.getJSON(this._urlFor('read', id), null, function (data, textStatus) {
            var results;
            if (textStatus === 'success') {
                self.annotations = id ? [data] : data;
                results = self.options.annotator.loadAnnotations(self.annotations);
            } else {
                throw('Annotation could not be loaded. [XHR returned "' + textStatus + '"]');
            }
        });
    },

    loadAnnotations: function () { this.loadAnnotation(null); },

    handleBackendError: function (xhrobj, textStatus, errorThrown) {
        alert("The annotation store backend encountered an error! " +
              "Your changes may not have been saved. " +
              "Refresh the page or see the console for more details.");
        console.error("AJAX error - { status: ", textStatus, ", error: ", errorThrown, " }");
        console.error("AJAX error - XMLHTTPRequest object: ", xhrobj);
    },

    _urlFor: function (action, id) {
        var url = this.options.prefix ? this.options.prefix : '/';
        return url + this.options.urls[action].replace(/:id/, id || '');
    },

    _dataFor: function (annotation) {
        // Store a reference to the highlights array. We can't serialize
        // a list of HTML Element objects.
        var highlights = annotation.highlights;

        delete annotation.highlights;

        // Preload with extra data.
        $.extend(annotation, this.options.annotationData)
        var data = {json: $.toJSON(annotation)};

        // Restore the highlights array.
        annotation.highlights = highlights;

        return data;
    }
});

$.plugin('annotationStore', AnnotationStore);

})(jQuery);
