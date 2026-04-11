
module.exports = function(grunt) {

  grunt.initConfig({
    meta: {
      date: (new Date()).toUTCString()
    },
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      dist: {
        src: 'jquery.i18n.js',
        dest: 'jquery.i18n.min.js'
      }
    }
  });

  grunt.registerTask('build', function() {
    var content = grunt.file.read('src/jquery.i18n.js', 'utf-8');
    var output = grunt.template.process(content);
    grunt.file.write('jquery.i18n.js', output);
    grunt.log.ok('File jquery.i18n.js created.');
  });

  // update bower version
  grunt.registerTask('bower', function() {
    var pkg = grunt.file.readJSON('package.json');
    var bower = grunt.file.readJSON('bower.json');
    bower.version = pkg.version;
    grunt.file.write('bower.json', JSON.stringify(bower, null, 2));
  });

  grunt.registerTask('default', ['build', 'uglify']);

  grunt.loadNpmTasks('grunt-contrib-uglify');
};
