paths      = require './paths'
onError    = require './onerror'
gulp       = require 'gulp'
pipe       = require 'gulp-pipe'
plumber    = require 'gulp-plumber'
append     = require 'add-stream'
concat     = require 'gulp-concat'
uglify     = require 'gulp-uglify'
rename     = require 'gulp-rename'
cssmin     = require 'gulp-cssmin'
prefix     = require 'gulp-autoprefixer'
_          = require 'lodash'
browserify = require 'browserify'
source     = require 'vinyl-source-stream'

minifyJs = (filenames...) ->
  _.each filenames, (filename) ->
    pipe gulp.src("#{paths.dist.assets}/#{filename}.js"), [
      uglify(mangle: false),                      # minify js file
      rename(suffix: '.min'),                     # rename stream to <filename.min.js
      gulp.dest(paths.dist.assets)                # write assets/<filename>.min.js
    ]

minifyBundle = (filenames...) ->
  _.each filenames, (filename) ->
    browserify("#{paths.dist.assets}/#{filename}.js")
      .transform('uglifyify')
      .bundle()
      .pipe(source("#{filename}.min.js"))
      .pipe(gulp.dest(paths.dist.assets))


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
    js:     -> minifyJs 'vendor', 'execjs'
    bundle: -> minifyBundle 'bundle'
    css:    -> minifyCss 'app', 'plugin'
  vue:
    js:     -> minifyBundle 'vue'
    css:    -> minifyCss 'vue'
