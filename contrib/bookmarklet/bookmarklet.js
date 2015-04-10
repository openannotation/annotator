/*
Annotator Bookmarklet
=====================

A Javascript bookmarklet wrapper around the Annotator plugin. This allows the
user to load the annotator into any web page and post the annotations to a
server (by default this is [AnnotateIt][#annotateit]).

The bookmarklet version of the annotator has the following plugins loaded:

 - [Auth][#wiki-auth]: authenticates with [AnnotateIt][#annotateit]
 - [Store][#wiki-store]: saves to [AnnotateIt][#annotateit]
 - [Permissions][#wiki-permissions]
 - [Unsupported][#wiki-unsupported]: displays a notification if the bookmarklet is run on an
   unsupported browser

and optionally, the [Tags plugin][#wiki-tags].

Configuration
-------------

In order to configure the bookmarklet for your needs it accepts `config` hash of
options. These are set in the _config.json_ file. There's an example in the
repository (see _config.example.json_). The options are as follows:

### externals

 - `source`: The generated Annotator Javascript source code (see Development)
 - `styles`: The generated Annotator CSS source code (see Development)

### auth

Settings for the [Auth plugin][#wiki-auth]

- `tokenUrl`: The URL of the auth token generator to use (default: http://annotateit.org/api/token)

### store

Settings for the [Store plugin][#wiki-store].

 - `prefix`: The prefix URL for the store (default: http://annotateit.org/api)

### permissions

Settings for the [Permissions plugin][#wiki-permissions].

#### tags

If this is set to `true` the [Tags plugin][#wiki-tags] will be loaded.
*/
(function (options, window, document) {
  "use strict";

  var body = document.body,
      head = document.getElementsByTagName('head')[0],
      globals = ['Annotator'],
      isLoaded = {},
      bookmarklet = {},
      notification, namespace;

  while (globals.length) {
    namespace = globals.shift();
    // window.hasOwnProperty doesn't exist in older IE, so we use
    // Object.prototype.hasOwnProperty which does exist.
    // https://github.com/openannotation/annotator/issues/420
    isLoaded[namespace] = Object.prototype.hasOwnProperty.call(window, namespace);
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

    _injectElement: function (where, el) {
      if (where == 'head') {
        head.appendChild(el);
      } else {
        body.appendChild(el);
      }
    },

    load: function (callback) {
      var annotatorSource = this.config('externals.source', 'http://assets.annotateit.org/bookmarklet/annotator-bookmarklet.min.js'),
          annotatorStyles = this.config('externals.styles', 'http://assets.annotateit.org/bookmarklet/annotator.min.css');

      var link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = annotatorStyles;

      var script = document.createElement('script');
      script.type = 'text/javascript';
      script.src = annotatorSource;
      script._loaded = false;

      var scriptLoaded = function () {
        if(script._loaded !== true) {
          script._loaded = true;
          callback();
        }
      };

      script.onload = scriptLoaded;
      script.onreadystatechange = function() {
        if ( this.readyState === "loaded" ) {
          scriptLoaded();
        }
      };

      setTimeout(function () {
        if (!script._loaded) {
          notification.error('Sorry, we\'re unable to load Annotator at the moment...');
        }
      }, 30000);

      this._injectElement('head', link);
      this._injectElement('body', script);
    },

    authOptions: function () {
      return {
        tokenUrl: this.config('auth.tokenUrl', 'http://annotateit.org/api/token'),
        autoFetch: this.config('auth.autoFetch', true)
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
      var annotator = new window.Annotator(options.target || body),
        jQuery = window.Annotator.Util.$,
        namespace;

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
          try {
            delete window[namespace];
          } catch(e) {
            window[namespace] = undefined;
          }
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
        bookmarklet.load(function () {
          bookmarklet.setup();
        });
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
  }
}(window._annotatorConfig, window, window.document));
