# writes dist/javascripts/app.min.js and app.min.css
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
    uglify(),                                   # minify app.js file
    rename(suffix: '.min'),                     # rename stream to app.min.js
    gulp.dest(paths.dist.assets)                # write assets/app.min.js
  ]
