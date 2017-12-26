# writes dist/javascripts/app.min.js
paths    = require './paths'
onError  = require './onerror'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'
plumber  = require 'gulp-plumber'
append   = require 'add-stream'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
rename   = require 'gulp-rename'
cssmin   = require 'gulp-cssmin'
prefix   = require 'gulp-autoprefixer'
_        = require 'lodash'

minifyJs = (filenames...) ->
  _.each filenames, (filename) ->
    pipe gulp.src("#{paths.dist.assets}/#{filename}.js"), [
      uglify(mangle: false),                      # minify js file
      rename(suffix: '.min'),                     # rename stream to <filename.min.js
      gulp.dest(paths.dist.assets)                # write assets/<filename>.min.js
    ]

minifyCss = (filenames...) ->
  _.each filenames, (filename) ->
    pipe gulp.src("#{paths.dist.assets}/#{filename}.css"), [
      plumber(errorHandler: onError),                # handle errors gracefully
      prefix(browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Safari >= 9'], cascade: false),
      cssmin(),                                      # minify <filename>.css file
      rename(suffix: '.min'),                        # rename stream to <filename>.min.css
      gulp.dest(paths.dist.assets)                   # write assets/<filename>.min.css
    ]

module.exports =
  app:
    js:  -> minifyJs 'app', 'plugin', 'vendor', 'execjs'
    css: -> minifyCss 'app', 'plugin'
  vue:
    js:  -> minifyJs 'vue'
    css: -> minifyCss 'vue'
