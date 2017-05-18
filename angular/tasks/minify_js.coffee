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

module.exports = ->
  pipe gulp.src(paths.dist.assets+'/app.js'), [
    uglify(mangle: false),                      # minify app.js file
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
