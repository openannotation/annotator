module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    copy: {
      main: {
        files: [
        { expand: true, cwd: './compiled-css', src: '*.css', dest: '../' },
        { expand: true, cwd: './compiled-css', src: '*.map', dest: '../' },

        ]
      }
    },

    sass: {
      build: {
        options: {
          style: 'expanded',
          precision: 8
        },
        files: {
          './compiled-css/annotator.css': './annotator.scss'
        }
      }
    },

    cssmin: {
      options: {
        shorthandCompacting: false,
        roundingPrecision: -1,
        sourceMap:true
      },
      target: {
        files: {
          './compiled-css/annotator.min.css': ['./compiled-css/annotator.css']
        }
      }
    },

    nodeunit: {
      all: ['test/*_tests.js']
    }
  });

  // load all grunt tasks
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-sass');


  //Compile Sass, minify the css, and place files in the css folder
  grunt.registerTask('default', ['sass', 'cssmin', 'copy']);

  //Compile Sass, and minify the css. Doesn't replace the css files
  grunt.registerTask('min', ['sass', 'cssmin']);


  //travis CI task
  grunt.registerTask('travis', ['sass', 'cssmin', 'copy', 'nodeunit']);

};
