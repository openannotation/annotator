BROWSERIFY := node_modules/.bin/browserify
UGLIFYCSS := node_modules/.bin/uglifycss
UGLIFYJS := node_modules/.bin/uglifyjs

# Check that the user has run 'npm install'
ifeq ($(shell which $(BROWSERIFY) >/dev/null 2>&1; echo $$?), 1)
$(error The 'browserify' command was not found. Please ensure you have run 'npm install' before running make.)
endif

# These are the plugins which are built separately and included in the
# annotator-full build. Not all of the plugins in src/plugin are suited for this
# at the moment.
PLUGINS := \
	document \
	filter \
	unsupported
PLUGINS_PKG := $(patsubst %,pkg/annotator.%.js,$(PLUGINS))

SRC := $(shell find src -type f -name '*.js')

all: annotator plugins annotator-full

annotator: pkg/annotator.min.js pkg/annotator.min.css
plugins: $(patsubst %.js,%.min.js,$(PLUGINS_PKG))
annotator-full: pkg/annotator-full.min.js pkg/annotator.min.css

clean:
	rm -rf .deps pkg

test:
	npm test

develop:
	npm start

doc:
	cd doc && $(MAKE) html

apidoc: $(patsubst src/%.js,doc/api/%.rst,$(SRC))

doc/api/%.rst: src/%.js
	@mkdir -p $(@D)
	tools/apidoc $< >$@

pkg/%.min.css: pkg/%.css
	@echo Writing $@
	@$(UGLIFYCSS) $< >$@

pkg/%.min.js: pkg/%.js
	@echo Writing $@
	@$(UGLIFYJS) --preamble "$$(tools/preamble)" $< >$@

pkg/annotator.css: css/annotator.css
	@mkdir -p pkg/
	@tools/data_uri_ify <$< >$@

pkg/annotator.js: src/annotator.js
	@mkdir -p pkg/ .deps/
	@$(BROWSERIFY) -s Annotator $< >$@
	@$(BROWSERIFY) --list $< | \
	sed 's#^#$@: #' >.deps/annotator.d

pkg/annotator.%.js: src/plugin/%.js
	@mkdir -p pkg/ .deps/
	@$(BROWSERIFY) -i annotator $< >$@
	@$(BROWSERIFY) --list -i annotator $< | \
	sed 's#^#$@: #' >.deps/annotator.$*.d

pkg/annotator-full.js: pkg/annotator.js $(PLUGINS_PKG)
	@cat $^ > $@

-include .deps/*.d

.PHONY: all annotator plugins annotator-full clean test develop doc
