BROWSERIFY := node_modules/.bin/browserify
UGLIFYJS := node_modules/.bin/uglifyjs

# Check that the user has run 'npm install'
ifeq ($(shell which $(BROWSERIFY) >/dev/null 2>&1; echo $$?), 1)
$(error The 'browserify' command was not found. Please ensure you have run 'npm install' before running make.)
endif

SRC := $(shell find src -type f -name '*.js')

all: annotator
annotator: pkg/annotator.min.js

pkg/%.min.js: pkg/%.js
	@echo Writing $@
	@$(UGLIFYJS) --preamble "$$(tools/preamble)" $< >$@

pkg/annotator.js: browser.js
	@echo Writing $@
	@mkdir -p pkg/ .deps/
	@$(BROWSERIFY) -s annotator $< >$@
	@$(BROWSERIFY) --list $< | \
	sed 's#^#$@: #' >.deps/annotator.d

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

.PHONY: all annotator clean test develop doc
