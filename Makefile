vpath %.coffee src:src/plugin

ANNOTATOR_SRC := annotator.coffee
ANNOTATOR_PKG := pkg/annotator.js pkg/annotator.css

PLUGIN_SRC := $(wildcard src/plugin/*.coffee)
PLUGIN_SRC := $(patsubst src/plugin/%,%,$(PLUGIN_SRC))
PLUGIN_PKG := $(patsubst %.coffee,pkg/annotator.%.js,$(PLUGIN_SRC))

PKG := $(ANNOTATOR_PKG) $(PLUGIN_PKG) pkg/annotator-full.js

BUILD := ./tools/build
DEPS := ./tools/build -d

DEPDIR := .deps
df = $(DEPDIR)/$(*F)

all: annotator plugins
default: all

annotator: $(ANNOTATOR_PKG)
plugins: $(PLUGIN_PKG)
annotator-full: pkg/annotator-full.js

pkg: $(PKG)
	cp package.json main.js index.js pkg/
	cp AUTHORS pkg/
	cp LICENSE* pkg/
	cp README* pkg/
	cp -R lib/ pkg/

clean:
	rm -rf .deps/* pkg/*

test:
	npm test

develop:
	npm start

pkg/annotator.css: css/annotator.css
	$(BUILD) -c

pkg/%.js pkg/annotator.%.js: %.coffee
	$(eval $@_CMD := $(patsubst annotator.%.js,-p %.js,$(@F)))
	$(eval $@_CMD := $(subst .js,,$($@_CMD)))
	$(BUILD) $($@_CMD)
	@$(DEPS) $($@_CMD) \
		| sed -n 's/^\(.*\)/pkg\/$(@F): \1/p' \
		| sort | uniq > $(df).d

pkg/annotator-full.js: $(ANNOTATOR_PKG) $(PLUGIN_PKG)
	$(BUILD) -a

-include $(ANNOTATOR_SRC:%.coffee=$(DEPDIR)/%.d)
-include $(PLUGIN_SRC:%.coffee=$(DEPDIR)/%.d)

.PHONY: all annotator plugins annotator-full clean test develop pkg
