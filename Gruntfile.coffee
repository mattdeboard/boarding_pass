allSourceFiles = [
    'Gruntfile.coffee'
    'js/*.coffee'
]

module.exports = (grunt) ->
    pkg = grunt.file.readJSON 'package.json'
    manifest = grunt.file.readJSON 'js/manifest.json'

    grunt.initConfig
        allSourceFiles: allSourceFiles
        pkg: pkg
        manifest: manifest
        coffee:
            compile:
                files:
                    'build/app.js': 'js/app.coffee'
                    'build/background.js': 'js/background.coffee'
        copy:
            main:
                files: [
                    {
                        expand: true
                        flatten: true
                        src: ['js/manifest.json']
                        dest: 'build/'
                    },
                    {
                        expand: true
                        flatten: true
                        src: [ 'static/html/background.html' ]
                        dest: 'build/'
                    }
                ]
        concat:
            dist:
                src: [
                    'build/db.min.js',
                    'bower_components/underscore/underscore.js',
                    'bower_components/jquery/jquery.js',
                    'build/app.js'
                ],
                dest: 'build/main.js'
        compress:
            chrome:
                options:
                    mode: 'zip'
                    archive: 'dist/celeb-pc-chrome.zip'
                expand: true
                cwd: 'build'
                src: [ '*.js', 'manifest.json', 'background.html' ]
        uglify:
            my_target:
                files:
                    'build/deps.js': [ 'bower_components/**/*.js' ]
            dbjs:
                files:
                    'build/db.min.js': [ 'js/db.js' ]
        requirejs:
            compile:
                options:
                    optimize: "none"
                    baseUrl: "js"
                    mainConfigFile: "js/config.js"
                    name: 'cs!main'
                    out: "build/require.js"

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-compress'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-contrib-requirejs'
    grunt.registerTask 'default', [
        'coffee',
        'uglify:dbjs',
        'concat',
        'copy',
        'compress:chrome',
        # 'requirejs'
    ]
