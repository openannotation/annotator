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
        transition = 'top 0.4s ease-out, color 0.3s linear',
        styles  = {
          display: 'block',
          position: 'fixed',
          fontFamily: 'Helvetica, Arial, sans-serif',
          fontSize: '14px',
          color: '#706446',
          top: '-40px',
          left: 0,
          width: '100%',
          lineHeight: '40px',
          fontSize: '14px',
          textAlign: 'center',
          backgroundColor: '#FDF5D8',
          borderBottom: '1px solid',
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

    if (element.style.position !== 'fixed') {
      element.style.position = 'absolute';
    }

    body.appendChild(element);

    function intToHex(integer) {
      var hex;
      integer = (integer < 0)   ? 0   :
                (integer > 255) ? 255 : integer;

      hex = (integer).toString(16);
      return (hex.length === 1) ? '0' + hex : hex;
    }

    function rgbToHex(rgb, offset) {
      offset = offset || 0;
      return [
        '#',
        intToHex(rgb[0] + offset),
        intToHex(rgb[1] + offset),
        intToHex(rgb[2] + offset)
      ].join('');
    }

    return {
      status: {
        INFO:    [253, 245, 216],
        SUCCESS: [217, 255, 198],
        ERROR:   [255, 148, 148]
      },
      show: function (message, status) {
        this.message(message);
        element.style.display = 'block';
        element.style.visibility = 'visible';
        element.style.top = '0';
      },
      hide: function () {
        element.style.top = '-40px';
        setTimeout(function () {
          element.style.display = 'none';
          element.style.visibility = 'hidden';
        }, 400);
      },
      message: function (message, status) {
        status = status || this.status.INFO;

        element.style.backgroundColor = rgbToHex(status);
        element.style.borderColor = rgbToHex(status, -100);
        element.style.color = rgbToHex(status, -150);

        element.innerHTML = message;
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
      instance: annotator
    };

    status.message('Annotator is ready!', status.status.SUCCESS);
    setTimeout(status.hide, 3000);
  }

  if (window._annotator) {
    window._annotator.instance.constructor.showNotification(
      'Annotator is already loaded into this page'
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
