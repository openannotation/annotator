vpath %.coffee ../src

SHELL := /bin/bash
PATH := $(shell npm bin):$(PATH)

ANNOTATOR=\
	xpath.coffee \
	util.coffee \
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
	plugin/document.coffee \
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

_preamble.map:
	@../tools/preamble > _preamble.coffee
	@coffee -mcb --no-header _preamble.coffee

annotator.js: $(ANNOTATOR) _preamble.map
	@cd ..; coffeebarx $(addprefix src/, $(ANNOTATOR)) -xso pkg/_annotator.js
	@mapcat _preamble.map _annotator.map -m annotator.map -j annotator.js

annotator-full.js: $(ANNOTATOR_FULL) _preamble.map
	@cd ..; coffeebarx $(addprefix src/, $(ANNOTATOR_FULL)) -xso pkg/_annotator-full.js
	@mapcat _preamble.map _annotator-full.map -m annotator-full.map -j annotator-full.js

annotator.css: ../css/annotator.css
	@../tools/data_uri_ify <../css/annotator.css >annotator.css

bookmarklet: annotator-bookmarklet.min.js annotator.min.css bookmarklet.min.js

annotator-bookmarklet.js: $(BOOKMARKLET) _preamble.map
	@cd ..; coffeebarx $(addprefix src/, $(BOOKMARKLET)) -xso pkg/_annotator-bookmarklet.js
	@mapcat _preamble.map _annotator-bookmarklet.map -m annotator-bookmarklet.map -j annotator-bookmarklet.js

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

annotator.%.js: plugin/%.coffee _preamble.map
	@cd ..; coffeebarx -xso pkg/_$(basename $@).js pkg/$<
	@mapcat _preamble.map _$(basename $@).map -m $(basename $@).map -j $@

%.min.js: %.js _preamble.map
	@# Oh my god this is so horrible I want to die. Uglify doesn't add the
	@# "file" key to the output map, so we manually inject it... with sed.
	@echo $@
	@if [ -e $(basename $<).map ]; then \
	  uglifyjs $< --source-map _$(basename $<).min.map --in-source-map $(basename $<).map > _$@ 2>/dev/null ; \
	  sed -e 's/\("version":3,\)/\1"file":"'_$@'",/' -i.bak _$(basename $<).min.map ; \
	  mapcat _preamble.map _$(basename $<).min.map -m $(basename $<).min.map -j $@ ; \
	else \
	  uglifyjs $< > $@ 2>/dev/null ; \
	fi

%.min.css: %.css
	@echo $@
	@uglifycss $< >$@

locales:
	@cd ..; \
	for f in $(basename $(ANNOTATOR_FULL)); \
          do echo "lib/$$f.js"; \
        done | \
	xargs xgettext -Lpython -o- -k_t -kgettext --from-code=utf-8 \
	> locale/annotator.pot

clean:
	rm -rf *.js *.css *.map *.bak *_mapsrc _preamble* _tmp

# don't remove intermediate .js files when building plugins
.SECONDARY:

.PHONY: all annotator plugins annotator-full bookmarklet clean
