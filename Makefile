REPORTER=dot

test:
	./node_modules/.bin/mocha-phantomjs -R $(REPORTER) test/runner.html

.PHONY: test
