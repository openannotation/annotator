var data = require("sdk/self").data;
var tabs = require('sdk/tabs');
var { ToggleButton } = require('sdk/ui/button/toggle');
var btn_config = {};
var btn;

function tabToggle(tab) {
  if (btn.state('window').checked) {
    tab.attach({
      contentScript: [
        'var s = document.createElement("script");',
        's.setAttribute("src", "' + data.url('bookmarklet.js') + '");',
        'document.body.appendChild(s);'
      ]
    });
  } else {
    tab.attach({
      contentScript: [
        'if (window._annotator !== null) {',
          'var s = document.createElement("script");',
          's.setAttribute("src", "' + data.url('destroy.js') + '");',
          'document.body.appendChild(s);',
        '}'
      ]
    });
  }
}

btn_config = {
  id: 'annotateit',
  label: 'Annotate',
  icon: {
    '16': './16.png',
    '32': './32.png',
    '34': './34.png',
    '64': './64.png',
  },
  onClick: function(state) {
    tabToggle(tabs.activeTab);
  }
};

btn = ToggleButton(btn_config);

tabs.on('ready', function(tab) {
  tab.on('activate', tabToggle);
  tab.on('pageshow', tabToggle);
});
