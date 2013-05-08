vpath %.coffee ../src

PATH:=$(shell npm bin):$(PATH)

ANNOTATOR=\
	xpath.coffee \
	extensions.coffee \
	console.coffee \
	class.coffee \
	range.coffee \
	annotator.coffee \
	widget.coffee \
	editor.coffee \
	viewer.coffee \
	notification.coffee

PLUGINS=\
	plugin/annotateitpermissions.coffee \
	plugin/auth.coffee \
	plugin/filter.coffee \
	plugin/kitchensink.coffee \
	plugin/markdown.coffee \
	plugin/permissions.coffee \
	plugin/store.coffee \
	plugin/tags.coffee \
	plugin/unsupported.coffee

ANNOTATOR_FULL=\
	$(ANNOTATOR) \
	plugin/unsupported.coffee \
	plugin/auth.coffee \
	plugin/store.coffee \
	plugin/permissions.coffee \
	plugin/annotateitpermissions.coffee \
	plugin/filter.coffee \
	plugin/markdown.coffee \
	plugin/tags.coffee \
	plugin/kitchensink.coffee

BOOKMARKLET=\
	$(ANNOTATOR) \
	plugin/auth.coffee \
	plugin/store.coffee \
	plugin/permissions.coffee \
	plugin/annotateitpermissions.coffee \
	plugin/unsupported.coffee \
	plugin/tags.coffee

BOOKMARKLET_CFG=../contrib/bookmarklet/config.json
BOOKMARKLET_SRC=../contrib/bookmarklet/src/bookmarklet.js

all: annotator plugins annotator-full bookmarklet

annotator: annotator.min.js annotator.min.css

PLUGIN_NAMES=$(notdir $(PLUGINS))
plugins: $(addprefix annotator.,$(PLUGIN_NAMES:.coffee=.min.js))

annotator-full: annotator-full.min.js

annotator.js: $(ANNOTATOR)
	@(../tools/preamble && \
	  for f in $(ANNOTATOR); do cat ../src/"$$f"; done) | \
		coffee -ps > annotator.js

annotator-full.js: $(ANNOTATOR_FULL)
	@(../tools/preamble && \
	  for f in $(ANNOTATOR_FULL); do cat ../src/"$$f"; done) | \
		coffee -ps > annotator-full.js

annotator.css: ../css/annotator.css
	@../tools/data_uri_ify <../css/annotator.css >annotator.css

bookmarklet: annotator-bookmarklet.min.js annotator.min.css bookmarklet.min.js

annotator-bookmarklet.js: $(BOOKMARKLET)
	@(../tools/preamble && \
	  for f in $(BOOKMARKLET); do cat ../src/"$$f"; done) | \
	  coffee -ps > annotator-bookmarklet.js

BOOKMARKLET_CFG_DEP=$(shell [ -f $(BOOKMARKLET_CFG) ] && echo $(BOOKMARKLET_CFG))
bookmarklet.js: $(BOOKMARKLET_SRC) $(BOOKMARKLET_CFG_DEP)
	@if [ -r $(BOOKMARKLET_CFG) ]; then \
	  sed -e "/Leave __config__/d" \
	      -e "/^__config__$$/{r $(BOOKMARKLET_CFG)" -e 'd;}' \
	      <$(BOOKMARKLET_SRC) \
	      >bookmarklet.js; \
	else \
	  sed -e "/Leave __config__/d" \
	      <$(BOOKMARKLET_SRC) \
	      >bookmarklet.js; \
	fi

annotator.%.js: plugin/%.coffee
	@(../tools/preamble && cat $<) | coffee -ps >$@

%.min.js: %.js
	@echo $@
	@uglifyjs <$< >$@

%.min.css: %.css
	@echo $@
	@uglifycss $< >$@

clean:
	rm -f *.js *.css

# don't remove intermediate .js files when building plugins
.SECONDARY:

.PHONY: all annotator plugins annotator-full bookmarklet clean
