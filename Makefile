REPORTER=spec

default: all

.DEFAULT:
	cd pkg && $(MAKE) $@

test: develop
	./tools/test -R $(REPORTER)

develop:
	npm start

.PHONY: test develop
