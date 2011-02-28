(function (window, document, jQuery, undefined) {

  var body = document.body,
      head = document.getElementsByTagName('head')[0],
      jQuerySource = 'https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.js',
      domain  = 'http://localhost:8000/contrib/bookmarklet/pkg/',
      source  = 'annotator.min.js',
      styles  = 'annotator.min.css',
      _Annotator, status;

  // Cache any existing annotator.
  _Annotator = window.Annotator;

  status = (function () {
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
        INFO:    '#3665f9',
        SUCCESS: '#d4288e',
        ERROR:   '#ea2207'
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

  function loadjQuery() {
    var script = document.createElement('script');

    script.src = jQuerySource;
    script.onload = function () {
      jQuery = window.jQuery;

      body.removeChild(script);
      load(function () {
        jQuery.noConflict(true);
        setup();
      });
    };

    body.appendChild(script);
  }

  function load(callback) {
    head.appendChild($('<link />', {
      rel: 'stylesheet',
      href: domain + styles
    })[0]);

    jQuery.getScript(domain + source, callback);
  }

  function setup() {
    var annotator = jQuery(body).annotator().data('annotator'),
        uri = location.href.split(/#|\?/).shift();

    annotator
      .addPlugin('Unsupported')
      .addPlugin('Store', {
        prefix: 'http://uat.annotateit.org',
        annotationData: {
          'uri': uri
        },
        loadFromSearch: {
          'uri': uri,
          'all_fields': 1
        }
      })
      .addPlugin('Permissions', {
        user: 'Anonymous',
        permissions: {
          'read':   ['Anonymous'],
          'update': ['Anonymous'],
          'delete': ['Anonymous'],
          'admin':  ['Anonymous']
        }
      });

    // Attach the annotator to the window object so we can prevent it
    // being loaded twice.
    window._annotator = {
      jQuery: jQuery,
      element: body,
      instance: annotator,
      Annotator: annotator.constructor
    };

    // Re-assign the original Annotator back to its rightful place.
    window.Annotator = _Annotator;

    status.message('Annotator is ready!', status.status.SUCCESS);
    setTimeout(function () {
      status.hide();
      setTimeout(status.remove, 800);
    }, 3000);
  }

  if (window._annotator) {
    window._annotator.Annotator.showNotification(
      'Annotator is already loaded. Try highlighting some text to get started'
    );
  } else {
    status.show('Loading Annotator into page');

    if (jQuery === undefined || !jQuery.sub) {
      loadjQuery();
    } else {
      jQuery = jQuery.sub();
      load(setup);
    }
  }

}(this, this.document, this.jQuery));
