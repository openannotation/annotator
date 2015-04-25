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
            'test/init.js',

            // Test suites
            'test/spec/**/*_spec.js'
        ],

        preprocessors: {
            'node_modules/wgxpath/wgxpath.install.js': 'browserify',
            'test/**/*.js': 'browserify'
        },

        browserify: {
            debug: true
        },

        browsers: ['PhantomJS'],

        reporters: ['dots'],

        customLaunchers: {
            'SL_Chrome': {
                base: 'SauceLabs',
                browserName: 'chrome',
                version: '41'
            },
            'SL_Firefox': {
                base: 'SauceLabs',
                browserName: 'firefox',
                version: '36'
            },
            'SL_Safari': {
                base: 'SauceLabs',
                browserName: 'safari',
                platform: 'OS X 10.10',
                version: '8'
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
        }
    });

    if (process.env.TRAVIS) {
        var buildLabel = 'TRAVIS #' + process.env.TRAVIS_BUILD_NUMBER + ' (' + process.env.TRAVIS_BUILD_ID + ')';

        karma.sauceLabs = {
            build: buildLabel,
            startConnect: false,
            testName: 'Annotator',
            tunnelIdentifier: process.env.TRAVIS_JOB_NUMBER
        };

        // Travis/Sauce runs frequently time out before data starts coming back
        // from Sauce. This ups the timeout from 10 to 30 seconds.
        karma.browserNoActivityTimeout = 30 * 1000;

        karma.browsers = [process.env.BROWSER];
        karma.reporters = ['dots', 'saucelabs'];
    }
};
