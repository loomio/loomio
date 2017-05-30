# writes dist/app.min.css
paths    = require './paths'
onError  = require './onerror'
gulp     = require 'gulp'
pipe     = require 'gulp-pipe'
plumber  = require 'gulp-plumber'
append   = require 'add-stream'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
rename   = require 'gulp-rename'
cssmin = require 'gulp-cssmin'

module.exports = ->
  pipe gulp.src(paths.dist.assets+'/app.css'), [
    plumber(errorHandler: onError),                # handle errors gracefully
    cssmin(),                                      # minify app.css file
    rename(suffix: '.min'),                        # rename stream to app.min.css
    gulp.dest(paths.dist.assets)                   # write assets/app.min.css
  ]
