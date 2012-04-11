const STATE_DISABLED = 0
const STATE_ENABLED = 1
const STATE_ACTIVE = 2

const ICON_SIZE = 48

var enabled = false;
var loaded = false;

var canvas = document.createElement('canvas')
var icon = new Image()
icon.src = chrome.extension.getURL('img/annotator-icon-sprite.png')
icon.alt = 'Annotate'
icon.onload = setIcon

function setIcon() {
  var state = (loaded && enabled) ? STATE_ENABLED : STATE_DISABLED;
  var ctx = canvas.getContext('2d');
  ctx.drawImage(icon, ICON_SIZE * state, 0, ICON_SIZE, ICON_SIZE, 0, 0, 19, 19)
  chrome.browserAction.setIcon({
    imageData: ctx.getImageData(0, 0, 19, 19)
  })
}

chrome.browserAction.onClicked.addListener(function(tab) {
  var message = loaded ? (enabled ? 'hide' : 'show') : 'load'
  chrome.tabs.sendRequest(tab.id, {annotator: message}, function (response) {
    if (response.error) {
      throw response.error
    } else {
      if (!loaded) loaded = true
      enabled = !enabled;
    }
    setIcon()
  })
})
