(function (options, window, document, jQuery, undefined) {

  var body = document.body,
      head = document.getElementsByTagName('head')[0],
      bookmarklet = {},
      notification;

  notification = (function () {
    var element = document.createElement('div'),
        transition = 'top 0.4s ease-out',
        styles  = {
          display: 'block',
          position: 'absolute',
          fontFamily: '"Helvetica Neue", Arial, Helvetica, sans-serif',
          fontSize: '14px',
          color: '#fff',
          top: '-54px',
          left: 0,
          width: '100%',
          zIndex: 9999,
          lineHeight: '50px',
          fontSize: '14px',
          textAlign: 'center',
          backgroundColor: '#000',
          borderBottom: '4px solid',
          WebkitTransition: transition,
          MozTransition: transition,
          OTransition: transition,
          transition: transition
        }, property;

    element.className = 'annotator-bm-status';
    for (property in styles) {
      if (styles.hasOwnProperty(property)) {
        element.style[property] = styles[property];
      }
    }

    // Apply newer styles for modern browsers.
    element.style.position = 'fixed';
    element.style.backgroundColor = 'rgba(0, 0, 0, 0.9)';

    return {
      status: {
        INFO:    '#d4d4d4',
        SUCCESS: '#3665f9',
        ERROR:   '#ff7e00'
      },
      element: element,
      show: function (message, status) {
        this.message(message, status);

        element.style.display = 'block';
        element.style.visibility = 'visible';
        element.style.top = '0';

        return this;
      },
      hide: function () {
        element.style.top = '-54px';

        setTimeout(function () {
          element.style.display = 'none';
          element.style.visibility = 'hidden';
        }, 400);

        return this;
      },
      message: function (message, status) {
        status = status || this.status.INFO;

        element.style.borderColor = status;
        element.innerHTML = message;

        return this;
      },
      append: function () {
        body.appendChild(element);
        return this;
      },
      remove: function () {
        var parent = element.parentNode;
        if (parent) {
          parent.removeChild(element);
        }
        return this;
      }
    }.append();
  }());

  bookmarklet = {
    notification: notification,

    keypath: function (object, path, fallback) {
      var keys = (path || '').split('.'),
          key;

      while (object && keys.length) {
        key = keys.shift();

        if (object.hasOwnProperty(key)) {
          object = object[key];

          if (keys.length === 0 && object !== undefined) {
            return object;
          }
        } else {
          break;
        }
      }

      return (fallback == null) ? null : fallback;
    },

    config: function (path, fallback) {
      var value = this.keypath(options, path, fallback);

      if (value === null) {
        notification.show(
          'Sorry there was an error reading the bookmarklet setting for key: ' + path,
          notification.status.ERROR
        );
        setTimeout(notification.hide, 3000);
      }

      return value;
    },

    loadjQuery: function (callback) {
      var script   = document.createElement('script'),
          fallback = 'https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.js';

      script.src = this.config('externals.jQuery', fallback);
      script.onload = function () {
        body.removeChild(script);
        jQuery = jQuery.noConflict(true);
        callback();
      };

      body.appendChild(script);
    },

    load: function (callback) {
      head.appendChild(jQuery('<link />', {
        rel: 'stylesheet',
        href: this.config('externals.styles')
      })[0]);
      jQuery.getScript(this.config('externals.source'), callback);
    },

    storeOptions: function () {
      var uri = location.href.split(/#|\?/).shift();
      return {
        prefix: this.config('store.prefix'),
        annotationData: {
          'uri': uri
        },
        loadFromSearch: {
          'uri': uri,
          'all_fields': 1
        }
      };
    },

    permissionsOptions: function () {
      return {
        user: this.config('permissions.user'),
        permissions: this.config('permissions.permissions'),
        userId: function (user) {
          return user && user.id ? user.id : '';
        },
        userString: function (user) {
          return user && user.name ? user.name : '';
        }
      };
    },

    setup: function () {
      var annotator = new Annotator(options.target || body);

      annotator
        .addPlugin('Unsupported')
        .addPlugin('Store', this.storeOptions())
        .addPlugin('Permissions', this.permissionsOptions())
        // As we're not requesting the auth tokens for the bookmarklet we
        // don't need the Auth plugin. Instead we just need to set the required
        // headers on each request.
        .element.data('annotator:headers', this.config('auth.headers'));

      // Attach the annotator to the window object so we can prevent it
      // being loaded twice and test.
      jQuery.extend(window._annotator, {
        jQuery: jQuery,
        element: body,
        instance: annotator,
        Annotator: Annotator.noConflict()
      });

      notification.message('Annotator is ready!', notification.status.SUCCESS);
      setTimeout(function () {
        notification.hide();
        setTimeout(notification.remove, 800);
      }, 3000);
    },

    init: function () {
      if (window._annotator.instance) {
        window._annotator.Annotator.showNotification(
          'Annotator is already loaded. Try highlighting some text to get started'
        );
      } else {
        notification.show('Loading Annotator into page');

        if (window.jQuery === undefined || !window.jQuery.sub) {
          this.loadjQuery(this.setup);
        } else {
          jQuery = window.jQuery.sub();
          this.load(this.setup);
        }
      }
    }
  };

  // Export the bookmarklet to the window object for testing.
  window._annotator = {
    bookmarklet: bookmarklet
  };

  // Load the bookmarklet.
  if (!options.test) {
    init();
  }
}(__config__, this, this.document, this.jQuery));
