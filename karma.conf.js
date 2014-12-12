module.exports = function (karma) {
    karma.set({
        frameworks: ["mocha", "browserify"],

        files: [
            // Fixtures
            {pattern: 'test/fixtures/*.html', included: false},

            // IE-specific shims
            {pattern: 'node_modules/wgxpath/wgxpath.install.js', watched: false},

            // Test harness
            {pattern: 'node_modules/sinon/pkg/sinon.js', watched: false},
            {pattern: 'node_modules/sinon/pkg/sinon-ie.js', watched: false},

            // Test suites
            'test/spec/**/*_spec.js'
        ],

        exclude: [
            'test/spec/bootstrap_spec.js',
            'test/spec/plugin/auth_spec.js',
            'test/spec/plugin/markdown_spec.js'
        ],

        preprocessors: {
            'node_modules/wgxpath/wgxpath.install.js': 'browserify',
            'test/spec/**/*_spec.js': 'browserify'
        },

        browserify: {
            debug: true,
            prebundle: function (bundle) {
                // This is event is fired each time the bundle is built.
                bundle.on('reset', function () {
                    // This allows annotator-plugintools to require annotator
                    // as 'annotator' in the test environment.
                    bundle.require('./src/annotator', {expose: 'annotator'});
                });
            }
        },

        browsers: ['PhantomJS'],

        reporters: ['dots'],

        customLaunchers: {
            'SL_Chrome': {
                base: 'SauceLabs',
                browserName: 'chrome',
                version: '38'
            },
            'SL_Firefox': {
                base: 'SauceLabs',
                browserName: 'firefox',
                version: '33'
            },
            'SL_Safari': {
                base: 'SauceLabs',
                browserName: 'safari',
                platform: 'OS X 10.9',
                version: '7'
            },
            'SL_IE_8': {
                base: 'SauceLabs',
                browserName: 'internet explorer',
                platform: 'Windows 7',
                version: '8'
            },
            'SL_IE_9': {
                base: 'SauceLabs',
                browserName: 'internet explorer',
                platform: 'Windows 7',
                version: '9'
            },
            'SL_IE_10': {
                base: 'SauceLabs',
                browserName: 'internet explorer',
                platform: 'Windows 8',
                version: '10'
            },
            'SL_IE_11': {
                base: 'SauceLabs',
                browserName: 'internet explorer',
                platform: 'Windows 8.1',
                version: '11'
            }
        },

        sauceLabs: {
            testName: 'Annotator'
        }
    });

    if (process.env.TRAVIS) {
        var buildLabel = 'TRAVIS #' + process.env.TRAVIS_BUILD_NUMBER + ' (' + process.env.TRAVIS_BUILD_ID + ')';

        karma.sauceLabs.build = buildLabel;
        karma.sauceLabs.startConnect = false;
        karma.sauceLabs.tunnelIdentifier = process.env.TRAVIS_JOB_NUMBER;

        karma.browsers = [process.env.BROWSER];
        karma.reporters = ['dots', 'saucelabs'];
    }
};
