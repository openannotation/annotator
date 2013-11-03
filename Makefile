default: all

.DEFAULT:
	cd pkg && $(MAKE) $@

test:
	npm test

develop:
	npm start

.PHONY: test develop
