/*!
 * jQuery i18n plugin
 * @requires jQuery v1.1 or later
 *
 * See https://github.com/recurser/jquery-i18n
 *
 * Licensed under the MIT license.
 *
 * Version: 1.1.1 (Sun, 05 Jan 2014 05:26:50 GMT)
 */
(function($) {
  /**
   * i18n provides a mechanism for translating strings using a jscript dictionary.
   *
   */

  var __slice = Array.prototype.slice;

  /*
   * i18n property list
   */
  var i18n = {

  	dict: null,

    /**
     * load()
     *
     * Load translations.
     *
     * @param  property_list i18n_dict : The dictionary to use for translation.
     */
  	load: function(i18n_dict) {
      if (this.dict !== null) {
        $.extend(this.dict, i18n_dict);
      } else {
        this.dict = i18n_dict;
      }
  	},

    /**
     * _()
     *
     * Looks the given string up in the dictionary and returns the translation if
     * one exists. If a translation is not found, returns the original word.
     *
     * @param  string str           : The string to translate.
     * @param  property_list params.. : params for using printf() on the string.
     *
     * @return string               : Translated word.
     */
  	_: function (str) {
      dict = this.dict;
  		if (dict && dict.hasOwnProperty(str)) {
  			str = dict[str];
  		}
      args = __slice.call(arguments);
      args[0] = str;
  		// Substitute any params.
  		return this.printf.apply(this, args);
  	},

    /*
     * printf()
     *
     * Substitutes %s with parameters given in list. %%s is used to escape %s.
     *
     * @param  string str    : String to perform printf on.
     * @param  string args   : Array of arguments for printf.
     *
     * @return string result : Substituted string
     */
  	printf: function(str, args) {
  		if (arguments.length < 2) return str;
      args = $.isArray(args) ? args : __slice.call(arguments, 1);
      return str.replace(/([^%]|^)%(?:(\d+)\$)?s/g, function(p0, p, position) {
        if (position) {
          return p + args[parseInt(position)-1];
        }
        return p + args.shift();
      }).replace(/%%s/g, '%s');
  	}

  };

  /*
   * _t()
   *
   * Allows you to translate a jQuery selector.
   *
   * eg $('h1')._t('some text')
   *
   * @param  string str           : The string to translate .
   * @param  property_list params : Params for using printf() on the string.
   *
   * @return element              : Chained and translated element(s).
  */
  $.fn._t = function(str, params) {
    return $(this).html(i18n._.apply(i18n, arguments));
  };

  $.i18n = i18n;
})(jQuery);
