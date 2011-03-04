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

    body.appendChild(element);

    return {
      status: {
        INFO:    '#d4d4d4',
        SUCCESS: '#3665f9',
        ERROR:   '#ff7e00'
      },
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
      remove: function () {
        element.parentNode.removeChild(element);
        return this;
      }
    };
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

    loadjQuery: function () {
      var script = document.createElement('script');

      script.src = config('externals.jQuery', 'https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.js');
      script.onload = function () {
        jQuery = window.jQuery;

        body.removeChild(script);
        notification.load(function () {
          jQuery.noConflict(true);
          setup();
        });
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

    setup: function () {
      var annotator = jQuery(options.target || body).annotator().data('annotator'),
          uri = location.href.split(/#|\?/).shift();

      annotator
        .addPlugin('Unsupported')
        .addPlugin('Store', {
          prefix: this.config('store.prefix'),
          annotationData: {
            'uri': uri
          },
          loadFromSearch: {
            'uri': uri,
            'all_fields': 1
          }
        })
        .addPlugin('Permissions', {
          user: this.config('permissions.user'),
          permissions: this.config('permissions.permissions'),
          userId: function (user) {
            return user ? user.id : '';
          },
          userString: function (user) {
            return user ? user.name : '';
          }
        })
        // As we're not requesting the auth tokens for the bookmarklet we
        // don't need the Auth plugin. Instead we just need to set the required
        // headers on each request.
        .element.data('annotator:headers', config('auth.headers'));

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
          this.loadjQuery();
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
