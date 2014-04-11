vpath %.coffee src:src/plugin

ANNOTATOR_SRC := annotator.coffee
ANNOTATOR_PKG := pkg/annotator.js pkg/annotator.css

PLUGIN_SRC := $(wildcard src/plugin/*.coffee)
PLUGIN_SRC := $(patsubst src/plugin/%,%,$(PLUGIN_SRC))
PLUGIN_PKG := $(patsubst %.coffee,pkg/annotator.%.js,$(PLUGIN_SRC))

FULL_SRC := $(ANNOTATOR_SRC) $(PLUGIN_SRC)
FULL_PKG := pkg/annotator-full.js pkg/annotator.css

BOOKMARKLET_PKG := pkg/annotator-bookmarklet.js pkg/annotator.css \
	pkg/bootstrap.js

MISC_PKG := pkg/package.json pkg/main.js pkg/index.js \
	pkg/AUTHORS pkg/LICENSE-GPL pkg/LICENSE-MIT pkg/README.markdown

BUILD := ./tools/build
DEPS := ./tools/build -d

DEPDIR := .deps
df = $(DEPDIR)/$(*F)

PKGDIR := pkg

all: annotator plugins annotator-full bookmarklet
default: all

annotator: $(ANNOTATOR_PKG)
plugins: $(PLUGIN_PKG)
annotator-full: $(FULL_PKG)
bookmarklet: $(BOOKMARKLET_PKG)

dist: $(ANNOTATOR_PKG) $(PLUGIN_PKG) $(FULL_PKG) $(BOOKMARKLET_PKG) $(MISC_PKG)

clean:
	rm -rf .deps pkg

test:
	npm test

develop:
	npm start

doc: docco
	cd doc && $(MAKE) html
	docco src/*.coffee -o doc/_build/html/docco/

# Make the docco build timestamped off the docco.css file which is regenerated
# on every docco build. This, in concert with the next task, can ensure that we
# don't regenerate docco docs unless the source files have actually changed.
docco: doc/_build/html/src/docco.css

doc/_build/html/src/docco.css: $(wildcard src/**/*.coffee)
	$(shell npm bin)/docco src/**/*.coffee -o doc/_build/html/src

pkg/annotator.css: css/annotator.css
	$(BUILD) -c

pkg/%.js pkg/annotator.%.js: %.coffee

pkg/%.js pkg/annotator.%.js pkg/annotator-%.js: | $(DEPDIR) $(PKGDIR)
	$(eval $@_CMD := $(patsubst annotator.%.js,-p %.js,$(@F)))
	$(eval $@_CMD := $(subst .js,,$($@_CMD)))
	$(BUILD) $($@_CMD)
	@$(DEPS) $($@_CMD) \
		| sed -n 's/^\(.*\)/pkg\/$(@F): \1/p' \
		| sort | uniq > $(df).d

$(MISC_PKG):
	cp $(@F) pkg/

$(DEPDIR) $(PKGDIR):
	@mkdir -p $@

-include $(DEPDIR)/*.d

.PHONY: all annotator plugins annotator-full bookmarklet clean test develop \
	dist doc docco

.SECONDEXPANSION:
$(MISC_PKG): $$(@F)
