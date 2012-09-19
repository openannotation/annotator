/*
 * Listen for requests from the background scripts. Since the annotator code is
 * loaded in the page context, background events which interact with the
 * annotator user interface, such as showing or hiding the annotator need to be
 * handled here.
 */
chrome.extension.onRequest.addListener(
  function (request, sender, sendResponse) {
    var command = request.annotator
    if (command) {
      if (command === 'load') {
        $(document.body).annotator().annotator('setupPlugins')
        sendResponse({ok: true})
      } else {
        sendResponse({error: new TypeError("not implemented: " + command)})
      }
    }
  }
)
