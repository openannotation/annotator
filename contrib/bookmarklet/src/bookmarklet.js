(function (window, document, jQuery, undefined) {

  var jQuerySource = 'https://ajax.googleapis.com/ajax/libs/jquery/1.5.0/jquery.min.js';
      source  = 'http://localhost:8000/pkg/',
      scripts = ['annotator.min.js', 'annotator.store.min.js'],
      styles  = ['annotator.min.css'];

  function loadjQuery() {
    var script = document.createElement('script');

    script.src = jQuerySource;
    script.onload = function () {
      jQuery = window.jQuery;

      document.body.removeChild(script);
      load(function () {
        jQuery.noConflict(true);
        setup();
      });
    };

    document.body.appendChild(script);
  }

  function load(callback) {
    var total = scripts.length;

    jQuery.each(styles, function () {
      jQuery('head').append($('<link />', {
        rel: 'stylesheet',
        href: source + this
      }));
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
    jQuery(document.body).annotator();
  }


  if (jQuery === undefined || !jQuery.sub) {
    loadjQuery();
  } else {
    jQuery = jQuery.sub();
    load(setup);
  }

}(this, this.document, this.jQuery));
