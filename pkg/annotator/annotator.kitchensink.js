/*
** Annotator v1.2.6
** https://github.com/okfn/annotator/
**
** Copyright 2012 Aron Carroll, Rufus Pollock, and Nick Stenning.
** Dual licensed under the MIT and GPLv3 licenses.
** https://github.com/okfn/annotator/blob/master/LICENSE
**
** Built at: 2013-01-21 09:43:49Z
*/

(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Annotator.prototype.setupPlugins = function(config, options) {
    var name, opts, pluginConfig, plugins, uri, win, _i, _len, _results;
    if (config == null) config = {};
    if (options == null) options = {};
    win = util.getGlobal();
    plugins = ['Unsupported', 'Auth', 'Tags', 'Filter', 'Store', 'AnnotateItPermissions'];
    if (win.Showdown) plugins.push('Markdown');
    uri = win.location.href.split(/#|\?/).shift() || '';
    pluginConfig = {
      Tags: {},
      Filter: {
        filters: [
          {
            label: Annotator._t('User'),
            property: 'user'
          }, {
            label: Annotator._t('Tags'),
            property: 'tags'
          }
        ]
      },
      Auth: {
        tokenUrl: config.tokenUrl || 'http://annotateit.org/api/token'
      },
      Store: {
        prefix: config.storeUrl || 'http://annotateit.org/api',
        annotationData: {
          uri: uri
        },
        loadFromSearch: {
          uri: uri
        }
      }
    };
    for (name in options) {
      if (!__hasProp.call(options, name)) continue;
      opts = options[name];
      if (__indexOf.call(plugins, name) < 0) plugins.push(name);
    }
    $.extend(true, pluginConfig, options);
    _results = [];
    for (_i = 0, _len = plugins.length; _i < _len; _i++) {
      name = plugins[_i];
      if (!(name in pluginConfig) || pluginConfig[name]) {
        _results.push(this.addPlugin(name, pluginConfig[name]));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

}).call(this);
