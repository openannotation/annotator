@echo off
type xpath.coffee util.coffee console.coffee class.coffee range.coffee annotator.coffee widget.coffee editor.coffee viewer.coffee notification.coffee > ..\pkg\annotator.coffee
rem coffee.cmd --map --compile --stdio > ../pkg/annotator.js
coffee.cmd --output ../pkg/ --map --compile ../pkg/annotator.coffee