BROWSERIFY := node_modules/.bin/browserify
UGLIFYJS := node_modules/.bin/uglifyjs
CLEANCSS := node_modules/.bin/cleancss
SASSC = node_modules/.bin/node-sass

# Check that the user has run 'npm install'
ifeq ($(shell which $(BROWSERIFY) >/dev/null 2>&1; echo $$?), 1)
$(error The 'browserify' command was not found. Please ensure you have run 'npm install' before running make.)
endif

# These are the annotator.ext modules which are built from this repository.
EXT := \
	document \
	unsupported

SRC := $(shell find src -type f -name '*.js')

all: annotator exts sass minifyCss

annotator: pkg/annotator.min.js
exts: $(patsubst %,pkg/annotator.%.min.js,$(EXT))

pkg/%.min.js: pkg/%.js
	@echo Writing $@
	@$(UGLIFYJS) --preamble "$$(tools/preamble)" $< >$@

# compile Sass
sass:
	@echo Compiling Styles
	mkdir -p css
	@$(SASSC) css/scss/annotator.scss > css/annotator.css

minifyCss:
	@echo Minfying Styles
	@$(CLEANCSS) --source-map --output css/annotator.min.css css/annotator.css

pkg/annotator.js: browser.js
	@mkdir -p pkg/ .deps/
	@$(BROWSERIFY) -s annotator $< >$@
	@$(BROWSERIFY) --list $< | \
	sed 's#^#$@: #' >.deps/annotator.d

pkg/annotator.%.js: src/ext/%.js
	@mkdir -p pkg/ .deps/
	@$(BROWSERIFY) $< >$@
	@$(BROWSERIFY) --list $< | \
	sed 's#^#$@: #' >.deps/annotator.$*.d

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
	tools/apidoc $< $@

-include .deps/*.d

.PHONY: all annotator exts sass minifyCss clean test develop doc
