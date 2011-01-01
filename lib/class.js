(function() {
  var $, Delegator, _ref;
  var __slice = Array.prototype.slice, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if (!(typeof jQuery != "undefined" && jQuery !== null ? (_ref = jQuery.fn) != null ? _ref.jquery : void 0 : void 0)) {
    console.error("Annotator requires jQuery: have you included lib/vendor/jquery.js?");
  }
  if (!(JSON && JSON.parse && JSON.stringify)) {
    console.error("Annotator requires a JSON implementation: have you included lib/vendor/json2.js?");
  }
  $ = jQuery;
  Delegator = (function() {
    Delegator.prototype.events = {};
    function Delegator(element, options) {
      this.options = $.extend(this.options, options);
      this.element = element;
    }
    Delegator.prototype.addEvents = function() {
      var event, functionName, sel, selector, _i, _ref, _ref2, _results;
      _ref = this.events;
      _results = [];
      for (sel in _ref) {
        functionName = _ref[sel];
        _ref2 = sel.split(' '), selector = 2 <= _ref2.length ? __slice.call(_ref2, 0, _i = _ref2.length - 1) : (_i = 0, []), event = _ref2[_i++];
        _results.push(this.addEvent(selector.join(' '), event, functionName));
      }
      return _results;
    };
    Delegator.prototype.addEvent = function(bindTo, event, functionName) {
      var closure, isBlankSelector;
      closure = __bind(function() {
        return this[functionName].apply(this, arguments);
      }, this);
      isBlankSelector = typeof bindTo === 'string' && bindTo.replace(/\s+/g, '') === '';
      if (isBlankSelector) {
        bindTo = this.element;
      }
      if (typeof bindTo === 'string') {
        return $(this.element).delegate(bindTo, event, closure);
      } else {
        return $(bindTo).bind(event, closure);
      }
    };
    return Delegator;
  })();
  this.Delegator = Delegator;
  $.plugin = function(name, object) {
    return $.fn[name] = function(options) {
      var args;
      args = Array.prototype.slice.call(arguments, 1);
      return this.each(function() {
        var instance;
        instance = $.data(this, name);
        if (instance) {
          return options && instance[options].apply(instance, args);
        } else {
          instance = new object(this, options);
          return $.data(this, name, instance);
        }
      });
    };
  };
}).call(this);
