(function() {
  var $;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  $ = jQuery;
  Annotator.Plugins.Store = (function() {
    __extends(Store, Delegator);
    Store.prototype.events = {
      'annotationCreated': 'annotationCreated',
      'annotationDeleted': 'annotationDeleted',
      'annotationUpdated': 'annotationUpdated'
    };
    Store.prototype.options = {
      prefix: '/store',
      autoFetch: true,
      annotationData: {},
      loadFromSearch: false,
      urls: {
        create: '/annotations',
        read: '/annotations/:id',
        update: '/annotations/:id',
        destroy: '/annotations/:id',
        search: '/search'
      }
    };
    function Store(element, options) {
      Store.__super__.constructor.apply(this, arguments);
      this.addEvents();
      this.annotations = [];
    }
    Store.prototype.pluginInit = function() {
      var auth, getAnnotations;
      getAnnotations = __bind(function() {
        if (this.options.loadFromSearch) {
          return this.loadAnnotationsFromSearch(this.options.loadFromSearch);
        } else {
          return this.loadAnnotations();
        }
      }, this);
      auth = $(this.element).data('annotator:auth');
      if (auth) {
        return auth.withToken(getAnnotations);
      } else {
        return getAnnotations();
      }
    };
    Store.prototype.annotationCreated = function(e, annotation) {
      if (__indexOf.call(this.annotations, annotation) < 0) {
        this.registerAnnotation(annotation);
        return this._apiRequest('create', annotation, __bind(function(data) {
          if (!(data.id != null)) {
            console.warn("Warning: No ID returned from server for annotation ", annotation);
          }
          return this.updateAnnotation(annotation, data);
        }, this));
      } else {
        return this.updateAnnotation(annotation, {});
      }
    };
    Store.prototype.annotationDeleted = function(e, annotation) {
      if (__indexOf.call(this.annotations, annotation) >= 0) {
        return this._apiRequest('destroy', annotation, (__bind(function() {
          return this.unregisterAnnotation(annotation);
        }, this)));
      }
    };
    Store.prototype.annotationUpdated = function(e, annotation) {
      if (__indexOf.call(this.annotations, annotation) >= 0) {
        return this._apiRequest('update', annotation, (__bind(function() {
          return this.updateAnnotation(annotation);
        }, this)));
      }
    };
    Store.prototype.registerAnnotation = function(annotation) {
      return this.annotations.push(annotation);
    };
    Store.prototype.unregisterAnnotation = function(annotation) {
      return this.annotations.splice(this.annotations.indexOf(annotation), 1);
    };
    Store.prototype.updateAnnotation = function(annotation, data) {
      if (__indexOf.call(this.annotations, annotation) < 0) {
        console.error("Trying to update unregistered annotation!");
      } else {
        $.extend(annotation, data);
      }
      return $(annotation.highlights).data('annotation', annotation);
    };
    Store.prototype.loadAnnotations = function() {
      return this._apiRequest('read', null, __bind(function(data) {
        this.annotations = data.slice();
        return this.annotator.loadAnnotations(data);
      }, this));
    };
    Store.prototype.loadAnnotationsFromSearch = function(searchOptions) {
      return this._apiRequest('search', searchOptions, __bind(function(data) {
        this.annotations = data.results.slice();
        return this.annotator.loadAnnotations(data.results);
      }, this));
    };
    Store.prototype.dumpAnnotations = function() {
      var ann, _i, _len, _ref, _results;
      _ref = this.annotations;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ann = _ref[_i];
        _results.push(JSON.parse(this._dataFor(ann)));
      }
      return _results;
    };
    Store.prototype._apiRequest = function(action, obj, onSuccess) {
      var onBeforeSend, onError, opts;
      onBeforeSend = __bind(function(xhr) {
        var headers, key, val, _results;
        headers = $(this.element).data('annotator:headers');
        if (headers) {
          _results = [];
          for (key in headers) {
            val = headers[key];
            _results.push(xhr.setRequestHeader(key, val));
          }
          return _results;
        }
      }, this);
      onError = function(xhr, status, errThrown) {
        return console.error("API request failed: '" + status + "'", xhr);
      };
      opts = {
        url: this._urlFor(action, obj && obj.id),
        type: this._methodFor(action),
        beforeSend: onBeforeSend,
        dataType: "json",
        success: onSuccess || function() {},
        error: onError
      };
      if (action === "search") {
        opts = $.extend(opts, {
          data: obj
        });
      } else {
        opts = $.extend(opts, {
          data: obj && this._dataFor(obj),
          contentType: "application/json; charset=utf-8"
        });
      }
      return $.ajax(opts);
    };
    Store.prototype._urlFor = function(action, id) {
      var replaceWith, url;
      replaceWith = id != null ? '/' + id : '';
      url = this.options.prefix || '/';
      url += this.options.urls[action];
      url = url.replace(/\/:id/, replaceWith);
      return url;
    };
    Store.prototype._methodFor = function(action) {
      var table;
      table = {
        'create': 'POST',
        'read': 'GET',
        'update': 'PUT',
        'destroy': 'DELETE',
        'search': 'GET'
      };
      return table[action];
    };
    Store.prototype._dataFor = function(annotation) {
      var data, highlights;
      highlights = annotation.highlights;
      delete annotation.highlights;
      $.extend(annotation, this.options.annotationData);
      data = JSON.stringify(annotation);
      annotation.highlights = highlights;
      return data;
    };
    return Store;
  })();
}).call(this);
