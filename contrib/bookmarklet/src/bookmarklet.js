(function (options, window, document) {
  "use strict";

  var body = document.body,
      head = document.getElementsByTagName('head')[0],
      globals = ['Annotator', '$', 'jQuery'],
      isLoaded = {},
      bookmarklet = {},
      notification, namespace, jQuery;

  while (globals.length) {
    namespace = globals.shift();
    isLoaded[namespace] = window.hasOwnProperty(namespace);
  }

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
    element.onclick = function () {
      this.parentNode.removeChild(this);
    };

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
      error: function (message) {
        this.message(message, this.status.ERROR);
        setTimeout(this.hide, 5000);
        setTimeout(this.remove, 5500);
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

      return (fallback === null) ? null : fallback;
    },

    config: function (path, fallback) {
      var value = this.keypath(options, path, fallback);

      if (value === null) {
        notification.error('Sorry, there was an error reading the bookmarklet setting for key: ' + path);
      }

      return value;
    },

    loadjQuery: function () {
      var script   = document.createElement('script'),
          fallback = 'https://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.js',
          timer;

      timer = setTimeout(function () {
        notification.error('Sorry, we were unable to load jQuery which is required by the annotator');
      }, this.config('timeout', 3000));

      script.src = this.config('externals.jQuery', fallback);
      script.onload = function () {
        // Reassign our local copy of jQuery.
        jQuery = window.jQuery;

        clearTimeout(timer);
        body.removeChild(script);
        bookmarklet.load(function () {
          // Once the Annotator has been loaded we can finally remove jQuery.
          window.jQuery.noConflict(true);
          bookmarklet.setup();
        });
      };

      body.appendChild(script);
    },

    load: function (callback) {
      var annotatorSource = this.config('externals.source', 'http://assets.annotateit.org/bookmarklet/annotator.min.js'),
          annotatorStyles = this.config('externals.styles', 'http://assets.annotateit.org/bookmarklet/annotator.min.css');

      head.appendChild(jQuery('<link />', {
        rel: 'stylesheet',
        href: annotatorStyles
      })[0]);

      jQuery.ajaxSetup({timeout: this.config('timeout', 3000)});
      jQuery.getScript(annotatorSource, callback)
            .error(function () {
              notification.error('Sorry, we\'re unable to load Annotator at the moment...');
            });
    },

    authOptions: function () {
      return {
        tokenUrl: this.config('auth.tokenUrl', 'http://annotateit.org/api/token')
      };
    },

    storeOptions: function () {
      var uri = location.href.split(/#|\?/).shift();
      return {
        prefix: this.config('store.prefix', 'http://annotateit.org/api'),
        annotationData: { 'uri': uri },
        loadFromSearch: { 'uri': uri }
      };
    },

    annotateItPermissionsOptions: function () {
      return this.config('annotateItPermissions', {});
    },

    setup: function () {
      var annotator = new window.Annotator(options.target || body), namespace;

      annotator
        .addPlugin('Unsupported')
        .addPlugin('Auth', this.authOptions())
        .addPlugin('Store', this.storeOptions())
        .addPlugin('AnnotateItPermissions', this.annotateItPermissionsOptions());

      if (this.config('tags') === true) {
          annotator.addPlugin('Tags');
      }

      // Attach the annotator to the window object so we can prevent it
      // being loaded twice and test.
      jQuery.extend(window._annotator, {
        jQuery: jQuery,
        element: body,
        instance: annotator,
        Annotator: window.Annotator.noConflict()
      });

      // Clean up after ourselves by removing any properties on window that
      // were not there before.
      for (namespace in isLoaded) {
        if (isLoaded.hasOwnProperty(namespace) && !isLoaded[namespace]) {
          delete window[namespace];
        }
      }

      notification.message('Annotator is ready!', notification.status.SUCCESS);
      setTimeout(function () {
        notification.hide();
        setTimeout(notification.remove, 800);
      }, 3000);
    },

    init: function () {
      if (window._annotator.instance) {
        window._annotator.Annotator.showNotification(
          'Annotator is already loaded. Try highlighting some text to get started.'
        );
      } else {
        notification.show('Loading Annotator into page');

        if (!window.jQuery || !window.jQuery.sub) {
          this.loadjQuery();
        } else {
          jQuery = window.jQuery.sub();
          this.load(jQuery.proxy(this.setup, this));
        }
      }
    }
  };

  // Export the bookmarklet to the window object for testing.
  if (!window._annotator) {
    window._annotator = {
      bookmarklet: bookmarklet
    };
  }

  // Load the bookmarklet.
  if (!options.test) {
    bookmarklet.init();
  } else {
    // jQuery is included here for testing individual methods. It is overridden
    // with a local copy later in the script. When checking for an external copy
    // always check window.jQuery.
    jQuery = window.jQuery;
  }
}(__config__, this, this.document));
