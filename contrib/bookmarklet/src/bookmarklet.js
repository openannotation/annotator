(function (window, document, jQuery, undefined) {

  var body = document.body,
      head = document.getElementsByTagName('head')[0],
      jQuerySource = 'https://ajax.googleapis.com/ajax/libs/jquery/1.5.0/jquery.min.js',
      source  = 'http://localhost:8000/pkg/',
      scripts = ['annotator.min.js', 'annotator.store.min.js'],
      styles  = ['annotator.min.css'],
      status;

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
    var total = scripts.length;

    jQuery.each(styles, function () {
      head.appendChild($('<link />', {
        rel: 'stylesheet',
        href: source + this
      })[0]);
    });

    jQuery.each(scripts, function () {
      jQuery.getScript(source + this, function () {
        total -= 1;

        if (total === 0) {
          callback();
        }
      });
    });
  }

  function setup() {
    var annotator = jQuery(body).annotator().data('annotator');

    // Attach the annotator to the window object so we can prevent it
    // being loaded twice.
    window._annotator = {
      jQuery: jQuery,
      element: body,
      instance: annotator,
      Annotator: annotator.constructor
    };

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
