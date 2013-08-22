module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    coffee:
      app:
        expand: true
        options:
          bare: true
        src: [ "./src/**/*.coffee" ]
        dest: "./build/"
        ext: ".js"
    copy:
      app:
        files: [
          expand: true
          src: [
            "./src/**/*.json"
          ]
          dest: "./build/"
        ]

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-copy"

  grunt.registerTask "default", ["copy", "coffee"]
