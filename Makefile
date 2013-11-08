vpath %.coffee src:src/plugin

ANNOTATOR_SRC := annotator.coffee
ANNOTATOR_PKG := pkg/annotator.js

PLUGIN_SRC := $(wildcard src/plugin/*.coffee)
PLUGIN_SRC := $(patsubst src/plugin/%,%,$(PLUGIN_SRC))
PLUGIN_PKG := $(patsubst %.coffee,pkg/annotator.%.js,$(PLUGIN_SRC))

BUILD := ./tools/build
DEPS := ./tools/build -d

DEPDIR := .deps
df = $(DEPDIR)/$(*F)

all: annotator plugins pkg
default: all

annotator: $(ANNOTATOR_PKG)
plugins: $(PLUGIN_PKG)
annotator-full:
	$(BUILD) -a

pkg/main.js pkg/package.json:
	cp $(@F) pkg/

pkg: pkg/main.js pkg/package.json

clean:
	rm -rf .deps/* pkg/*

test: annotator plugins
	npm test

develop:
	npm start

.PHONY: all annotator plugins clean test develop pkg

pkg/%.js pkg/annotator.%.js: %.coffee
	$(eval $@_CMD := $(patsubst annotator.%.js,-p %.js,$(@F)))
	$(eval $@_CMD := $(subst .js,,$($@_CMD)))
	@$(BUILD) $($@_CMD)
	@$(DEPS) $($@_CMD) \
		| sed -n 's/^\(.*\)/pkg\/$(*F).js: \1/p' \
		| sort | uniq > $(df).d

-include $(ANNOTATOR_SRC:%.coffee=$(DEPDIR)/%.d)
-include $(PLUGIN_SRC:%.coffee=$(DEPDIR)/%.d)
