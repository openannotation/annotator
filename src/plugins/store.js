;(function($){

function apiRequest (opts) {
  opts = $.extend({
    dataType: 'jsonp',
    success: function () {}
  }, opts)

  return $.ajax(opts)
}

Annotator.Plugins.Store = DelegatorClass.extend({
  events: {
    'annotationCreated': 'annotationCreated',
    'annotationDeleted': 'annotationDeleted',
    'annotationUpdated': 'annotationUpdated'
  },

  options: {
    prefix: '/store',

    annotationData: {},

    // If loadFromSearch is set, then we load the first batch of
    // annotations from 'prefix/search(options=loadFromSearch)'
    // instead of the registry path 'prefix/read'.
    //
    //     loadFromSearch: {
    //       'limit': 0,
    //       'all_fields': 1
    //       'uri': 'http://this/document/only'
    //     }
    loadFromSearch: false,

    urls: {
      'create':  '/annotations',     // POST
      'read':    '/annotations/:id', // GET
      'update':  '/annotations/:id', // POST/[PUT]
      'destroy': '/annotations/:id', // DELETE
      'search':  '/search'
    }
  },

  init: function (options, element) {
    this.options = $.extend(this.options, options)

    this.options.annotator = $(element).data('annotator')

    this.element = element
    this.annotations = []

    if (this.options.loadFromSearch) {
      this.loadAnnotationsFromSearch(this.options.loadFromSearch)
    } else {
      this.loadAnnotations()
    }

    this._super()
  },

  annotationCreated: function (e, annotation) {
    var self = this

    // Pre-register the annotation so as to save the list of highlight
    // elements.
    if (this.annotations.indexOf(annotation) === -1) {
      this.registerAnnotation(annotation)

      apiRequest({
        url: this._urlFor('create'),
        data: this._dataFor(annotation),
        type: 'POST',
        success: function (data) {
          // Update with (e.g.) ID from server.
          if (!("id" in data)) { console.warn("Warning: No ID returned from server for annotation ", annotation) }
          self.updateAnnotation(annotation, data)
        }
      })

    } else {
      // This is called to update annotations created at load time with
      // the highlight elements created by Annotator.
      this.updateAnnotation(annotation, {})
    }
  },

  annotationDeleted: function (e, annotation) {
    var self = this

    if ($.inArray(annotation, this.annotations) !== -1) {
      apiRequest({
        url: this._urlFor('destroy', annotation.id),
        type: 'DELETE',
        success: function () { self.unregisterAnnotation(annotation) }
      })
    }
  },

  annotationUpdated: function (e, annotation) {
    var self = this

    if ($.inArray(annotation, this.annotations) !== -1) {
      apiRequest({
        url: this._urlFor('update', annotation.id),
        type: 'POST',
        data: this._dataFor(annotation),
        success: function () { self.updateAnnotation(annotation) }
      })
    }
  },

  // NB: registerAnnotation and unregisterAnnotation do no error-checking/
  // duplication avoidance of their own. Use with care.
  registerAnnotation: function (annotation) {
    this.annotations.push(annotation)
  },

  unregisterAnnotation: function (annotation) {
    this.annotations.splice(this.annotations.indexOf(annotation), 1)
  },

  updateAnnotation: function (annotation, data) {
    if ($.inArray(annotation, this.annotations) === -1) {
      console.error("Trying to update unregistered annotation!")
    } else {
      $.extend(annotation, data)
    }

    // Update the elements with our copies of the annotation objects (e.g.
    // with ids from the server).
    $(annotation.highlights).data('annotation', annotation)
  },

  loadAnnotations: function () {
    var self = this

    apiRequest({
      url: this._urlFor('read'),
      type: 'GET',
      success: function (data) {
        self.annotations = data
        self.options.annotator.loadAnnotations(self.annotations)
      }
    })
  },

  loadAnnotationsFromSearch: function (searchOptions) {
    var self = this
    apiRequest({
      url: this._urlFor('search'),
      type: 'GET',
      data: searchOptions,
      success: function (data) {
        self.annotations = data.results
        self.options.annotator.loadAnnotations(self.annotations)
      }
    })
  },

  _urlFor: function (action, id) {
    var url = this.options.prefix || '/'
    url += this.options.urls[action].replace(/\/:id/, id ? '/' + id : '')
    return url
  },

  _dataFor: function (annotation) {
    // Store a reference to the highlights array. We can't serialize
    // a list of HTML Element objects.
    var highlights = annotation.highlights

    delete annotation.highlights

    // Preload with extra data.
    $.extend(annotation, this.options.annotationData)
    var data = { json: $.toJSON(annotation) }

    // Restore the highlights array.
    annotation.highlights = highlights

    return data
  }
})

})(jQuery)
