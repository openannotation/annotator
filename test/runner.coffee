jsdom = require 'jsdom'

documentSource = """
                 <html>
                   <head></head>
                   <body></body>
                 </html>
                 """

document = jsdom.jsdom(documentSource)
window = document.createWindow()

$ = require('jquery').create(window)

# for file in recursive_find('./spec')
#   fixture = document.clone()
#   jasmine.withFixture(fixture).runTestsForFile(file)

console.log "This doesn't do anything useful yet."