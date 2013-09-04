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

ANNOTATOR_MAPS=$(addprefix ../lib/, $(addsuffix .map, $(basename $(ANNOTATOR))))

annotator.js: $(ANNOTATOR)
	@../tools/preamble > _preamble.coffee
	@coffee -mcb _preamble.coffee
	@cd ..; \
	coffeebarx $(addprefix src/, $(ANNOTATOR)) -xso pkg/_annotator.js;
	@mapcat _preamble.map _annotator.map -m annotator.map -j annotator.js
	@rm -f _preamble.* _annotator.*

ANNOTATOR_FULL_MAPS=$(addprefix ../lib/, $(addsuffix .map, $(basename $(ANNOTATOR_FULL))))

annotator-full.js: $(ANNOTATOR_FULL)
	@../tools/preamble > _preamble.coffee
	@coffee -mcb _preamble.coffee
	@cd ..; \
	coffeebarx $(addprefix src/, $(ANNOTATOR_FULL)) -xso pkg/_annotator-full.js
	@mapcat _preamble.map _annotator-full.map -m annotator-full.map -j annotator-full.js
	@rm -f _preamble.* _annotator-full.*

annotator.css: ../css/annotator.css
	@../tools/data_uri_ify <../css/annotator.css >annotator.css

bookmarklet: annotator-bookmarklet.min.js annotator.min.css bookmarklet.min.js

BOOKMARKLET_MAPS=$(addprefix ../lib/, $(addsuffix .map, $(basename $(BOOKMARKLET))))

annotator-bookmarklet.js: $(BOOKMARKLET)
	@../tools/preamble > _preamble.coffee
	@coffee -mcb _preamble.coffee
	@cd ..; \
	coffeebarx $(addprefix src/, $(BOOKMARKLET)) -xso pkg/_annotator-bookmarklet.js
	@mapcat _preamble.map _annotator-bookmarklet.map -m annotator-bookmarklet.map -j annotator-bookmarklet.js
	@rm -f _preamble.* _annotator-bookmarklet.*

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
	@../tools/preamble > _preamble.coffee
	@coffee -mcb _preamble.coffee
	@rm -rf _tmp
	@mkdir _tmp
	@coffee -o _tmp -mc $<
	@mapcat _preamble.map _tmp/$(notdir $(basename $<).map) -m $(basename $@).map -j $@
	@rm -rf _preamble.* _tmp

%.min.js: %.js
	@echo $@
	@if [ -e $(basename $<).map ]; then \
	  uglifyjs $< --source-map $(basename $<).min.map --in-source-map $(basename $<).map > $@ 2>/dev/null ; \
	  echo "\n//@ sourceMappingURL=$(basename $<).min.map" >> $@; \
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
	rm -rf *.js *.css *.map *_mapsrc

# don't remove intermediate .js files when building plugins
.SECONDARY:

.PHONY: all annotator plugins annotator-full bookmarklet clean
