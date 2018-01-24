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

module.exports =
  js: ->
    pipe gulp.src(paths.dist.assets+'/app.js'), [
      uglify(mangle: false),                      # minify app.js file
      rename(suffix: '.min'),                     # rename stream to app.min.js
      gulp.dest(paths.dist.assets)                # write assets/app.min.js
    ]
    pipe gulp.src(paths.dist.assets+'/plugin.js'), [
      uglify(mangle: false),                      # minify plugin.js file
      rename(suffix: '.min'),                     # rename stream to app.min.js
      gulp.dest(paths.dist.assets)                # write assets/app.min.js
    ]
    pipe gulp.src(paths.dist.assets+'/vendor.js'), [
      uglify(),                                 # minify vendor.js
      rename(suffix: '.min'),                   # rename stream to vendor.min.js
      gulp.dest(paths.dist.assets)              # write assets/vendor.min.js
    ]
    pipe gulp.src(paths.dist.assets+'/execjs.js'), [
      uglify(mangle: false),                      # minify app.js file
      rename(suffix: '.min'),                   # rename stream to vendor.min.js
      gulp.dest(paths.dist.assets)              # write assets/vendor.min.js
    ]
  css: ->
    pipe gulp.src(paths.dist.assets+'/app.css'), [
      plumber(errorHandler: onError),                # handle errors gracefully
      prefix(browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Safari >= 9'], cascade: false),
      cssmin(),                                      # minify app.css file
      rename(suffix: '.min'),                        # rename stream to app.min.css
      gulp.dest(paths.dist.assets)                   # write assets/app.min.css
    ]
    pipe gulp.src(paths.dist.assets+'/plugin.css'), [
      plumber(errorHandler: onError),                # handle errors gracefully
      prefix(browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Safari >= 9'], cascade: false),
      cssmin(),                                      # minify app.css file
      rename(suffix: '.min'),                        # rename stream to plugin.min.css
      gulp.dest(paths.dist.assets)                   # write assets/plugin.min.css
    ]
