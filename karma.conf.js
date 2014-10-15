module.exports = function (karma) {
    karma.set({
        frameworks: ["mocha", "browserify"],

        files: [
            {pattern: 'test/fixtures/*.html', included: false},
            {pattern: 'node_modules/chai/chai.js', watched: false},
            {pattern: 'node_modules/sinon/pkg/sinon.js', watched: false},
            {pattern: 'node_modules/sinon/pkg/sinon-ie.js', watched: false},
            'test/init.js',
            'test/spec/**/*_spec.js'
        ],

        exclude: [
            'test/spec/bootstrap_spec.js',
            'test/spec/plugin/auth_spec.js',
            'test/spec/plugin/markdown_spec.js',
            'test/spec/plugin/tags_spec.js'
        ],

        preprocessors: {
            'test/spec/**/*_spec.js': 'browserify'
        },

        browserify: {
            debug: true,
            prebundle: function (bundle) {
                // This allows annotator-plugintools to require annotator as
                // 'annotator' in the test environment.
                bundle.require('./src/annotator', {expose: 'annotator'});
            }
        },

        browsers: ['PhantomJS']
    });
};
