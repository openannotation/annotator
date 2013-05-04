REPORTER=dot

default: all

.DEFAULT:
	cd pkg && $(MAKE) $@

test:
	./tools/test_phantom -R $(REPORTER)

.PHONY: test
