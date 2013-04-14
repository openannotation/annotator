REPORTER=dot

test:
	./tools/test_phantom -R $(REPORTER)

.PHONY: test
