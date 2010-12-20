;(function($){

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
    // annotations from the 'search' URL as set in `options.urls`
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
      'update':  '/annotations/:id', // PUT (since idempotent)
      'destroy': '/annotations/:id', // DELETE
      'search':  '/search'
    }
  },

  init: function (options, element) {
    var self = this

    this.options = $.extend(this.options, options)

    this.annotator = $(element).data('annotator')

    this.element = element
    this.annotations = []

    // We can't bind the event handlers until the initial load is done, or
    // we'd catch the annotationCreated events for our own load.
    var s = self._super
    var callback = function () { s.apply(self) }

    if (this.options.loadFromSearch) {
      this.loadAnnotationsFromSearch(this.options.loadFromSearch, callback)
    } else {
      this.loadAnnotations(callback)
    }
  },

  annotationCreated: function (e, annotation) {
    var self = this

    // Pre-register the annotation so as to save the list of highlight
    // elements.
    if (this.annotations.indexOf(annotation) === -1) {
      this.registerAnnotation(annotation)

      this._apiRequest('create', annotation, function (data) {
        // Update with (e.g.) ID from server.
        if (!("id" in data)) { console.warn("Warning: No ID returned from server for annotation ", annotation) }
        self.updateAnnotation(annotation, data)
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
      this._apiRequest('destroy', annotation, function () {
        self.unregisterAnnotation(annotation)
      })
    }
  },

  annotationUpdated: function (e, annotation) {
    var self = this

    if ($.inArray(annotation, this.annotations) !== -1) {
      this._apiRequest('update', annotation, function () {
        self.updateAnnotation(annotation)
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

  loadAnnotations: function (callback) {
    var self = this

    this._apiRequest('read', null, function (data) {
      self.annotations = data.slice() // Clone array
      self.annotator.loadAnnotations(data, callback)
    })
  },

  loadAnnotationsFromSearch: function (searchOptions, callback) {
    var self = this
    this._apiRequest('search', searchOptions, function (data) {
      self.annotations = data.results.slice() // Clone array
      self.annotator.loadAnnotations(data.results, callback)
    })
  },

  setAnnotationData: function (data) {
    this.options.annotationData = data
  },

  _apiRequest: function (action, obj, onSuccess) {
    var self = this

    // request payload
    var url, data
    if (action === 'search') {
      url = this._urlFor('search')
      data = obj
    } else if (obj) {
      url = this._urlFor(action, obj.id)
      data = this._dataFor(obj)
    } else {
      url = this._urlFor(action)
      data = {}
    }

    // set request headers before send
    var onBeforeSend = function (xhr) {
      var headers = $(self.element).data('annotator:headers')
      if (headers) {
        _(headers).each(function (val, key) {
          xhr.setRequestHeader(key, val)
        })
      }
    }

    // error handler
    var onError = function (xhr, status, errThrown) {
      console.error("API request failed: '" + status + "'", xhr)
    }

    return $.ajax({
      dataType:   'json',
      url:        url,
      type:       this._methodFor(action),
      data:       data,
      beforeSend: onBeforeSend,
      success:    onSuccess || function () {},
      error:      onError
    })
  },

  _urlFor: function (action, id) {
    var replaceWith = (typeof(id) === 'undefined') ? '' : '/' + id

    var url = this.options.prefix || '/'
    url += this.options.urls[action]
    url = url.replace(/\/:id/, replaceWith)

    return url
  },

  _methodFor: function (action) {
    var table = {
      'create':  'POST',
      'read':    'GET',
      'update':  'PUT',
      'destroy': 'DELETE',
      'search':  'GET'
    }

    return table[action]
  },

  _dataFor: function (annotation) {
    // Store a reference to the highlights array. We can't serialize
    // a list of HTMLElement objects.
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
